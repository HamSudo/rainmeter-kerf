using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Threading;
using Microsoft.Win32;

static class Kmt
{
    [StructLayout(LayoutKind.Sequential)] struct ADAPTERINFO { public uint hAdapter; public uint LuidLow; public int LuidHigh; public uint NumOfSources; public int Precise; }
    [StructLayout(LayoutKind.Sequential)] struct ENUM2 { public uint NumAdapters; public IntPtr pAdapters; }
    [StructLayout(LayoutKind.Sequential)] struct QUERY { public uint hAdapter; public int Type; public IntPtr pData; public uint Size; }
    [StructLayout(LayoutKind.Sequential)] struct CLOSE { public uint hAdapter; }

    [DllImport("gdi32.dll")] static extern int D3DKMTEnumAdapters2(ref ENUM2 e);
    [DllImport("gdi32.dll")] static extern int D3DKMTQueryAdapterInfo(ref QUERY q);
    [DllImport("gdi32.dll")] static extern int D3DKMTCloseAdapter(ref CLOSE c);

    const int ADAPTERREGISTRYINFO = 8, ADAPTERTYPE = 15, ADAPTERPERFDATA = 62;

    public static uint[] Open()
    {
        var e = new ENUM2();
        if (D3DKMTEnumAdapters2(ref e) != 0 || e.NumAdapters == 0) return new uint[0];
        int sz = Marshal.SizeOf(typeof(ADAPTERINFO));
        e.pAdapters = Marshal.AllocHGlobal(sz * (int)e.NumAdapters);
        try
        {
            if (D3DKMTEnumAdapters2(ref e) != 0) return new uint[0];
            var r = new uint[e.NumAdapters];
            for (int i = 0; i < r.Length; i++)
                r[i] = ((ADAPTERINFO)Marshal.PtrToStructure(new IntPtr(e.pAdapters.ToInt64() + i * sz), typeof(ADAPTERINFO))).hAdapter;
            return r;
        }
        finally { Marshal.FreeHGlobal(e.pAdapters); }
    }

    public static void Close(IEnumerable<uint> handles)
    {
        foreach (var h in handles) { var c = new CLOSE { hAdapter = h }; D3DKMTCloseAdapter(ref c); }
    }

    static int Query(uint h, int type, IntPtr buf, int size)
    {
        Marshal.Copy(new byte[size], 0, buf, size);
        var q = new QUERY { hAdapter = h, Type = type, pData = buf, Size = (uint)size };
        return D3DKMTQueryAdapterInfo(ref q);
    }

    public static string Name(uint h)
    {
        int size = 260 * 2 * 4; IntPtr b = Marshal.AllocHGlobal(size);
        try { return Query(h, ADAPTERREGISTRYINFO, b, size) == 0 ? Marshal.PtrToStringUni(b) : ""; }
        finally { Marshal.FreeHGlobal(b); }
    }

    public static uint Flags(uint h)
    {
        IntPtr b = Marshal.AllocHGlobal(4);
        try { return Query(h, ADAPTERTYPE, b, 4) == 0 ? (uint)Marshal.ReadInt32(b) : 0; }
        finally { Marshal.FreeHGlobal(b); }
    }

    public static int TempDeci(uint h)
    {
        IntPtr b = Marshal.AllocHGlobal(64);
        try { return Query(h, ADAPTERPERFDATA, b, 64) == 0 ? Marshal.ReadInt32(b, 56) : -1; }
        finally { Marshal.FreeHGlobal(b); }
    }
}

class Adapter { public uint Handle; public string Name; public bool Integrated; }

static class Program
{
    static readonly Regex Discrete = new Regex(@"nvidia|geforce|rtx|gtx|quadro|radeon rx|radeon pro|\brx \d|arc a\d|arc b\d", RegexOptions.IgnoreCase);
    static readonly Regex Integrated = new Regex(@"uhd|iris|intel\(r\) hd|intel hd|radeon\(tm\) graphics|radeon graphics|vega \d+ graphics|arc\(tm\) graphics|arc graphics", RegexOptions.IgnoreCase);

    static List<Adapter> GetAdapters()
    {
        var list = new List<Adapter>();
        foreach (var h in Kmt.Open())
        {
            uint flags = Kmt.Flags(h);
            if ((flags & 4) != 0) { Kmt.Close(new[] { h }); continue; }
            string name = Kmt.Name(h);
            bool disc = (flags & 16) != 0 || (flags & 1024) != 0 || Discrete.IsMatch(name);
            bool integ = !disc && ((flags & 32) != 0 || Integrated.IsMatch(name));
            list.Add(new Adapter { Handle = h, Name = name, Integrated = integ });
        }
        return list;
    }

    static List<KeyValuePair<string, PerformanceCounter>> zones;
    static bool tenths;

    static double? ReadCpu()
    {
        if (zones == null)
        {
            zones = new List<KeyValuePair<string, PerformanceCounter>>();
            try
            {
                var cat = new PerformanceCounterCategory("Thermal Zone Information");
                string counter = cat.CounterExists("High Precision Temperature") ? "High Precision Temperature" : "Temperature";
                tenths = counter.StartsWith("High");
                foreach (var n in cat.GetInstanceNames())
                    zones.Add(new KeyValuePair<string, PerformanceCounter>(n, new PerformanceCounter("Thermal Zone Information", counter, n, true)));
            }
            catch { }
        }
        double? best = null;
        foreach (var z in zones)
        {
            double k;
            try { k = z.Value.NextValue(); } catch { continue; }
            if (tenths) k /= 10;
            double c = Math.Round(k - 273.15, 1);
            if (c <= 5 || c >= 125) continue;
            if (z.Key.IndexOf("cpu", StringComparison.OrdinalIgnoreCase) >= 0) return c;
            if (best == null || c > best) best = c;
        }
        return best;
    }

    static string F(double? v) { return v.HasValue ? v.Value.ToString("0.0", System.Globalization.CultureInfo.InvariantCulture) : ""; }

    [STAThread]
    static void Main(string[] args)
    {
        bool once = args.Any(a => a == "--once");
        bool owned;
        using (var mutex = new Mutex(true, @"Local\KerfSensors", out owned))
        {
            if (!owned && !once) return;

            var adapters = GetAdapters();
            DateTime refreshed = DateTime.UtcNow;
            RegistryKey key = Registry.CurrentUser.CreateSubKey(@"Software\Kerf\Sensors");
            double? lastCpu = null, lastGpu = null; string lastKind = "", lastName = "";
            DateTime lastTemps = DateTime.MinValue;

            while (true)
            {
                if ((DateTime.UtcNow - lastTemps).TotalSeconds >= 10)
                {
                    lastTemps = DateTime.UtcNow;
                    if ((DateTime.UtcNow - refreshed).TotalSeconds > 60)
                    {
                        Kmt.Close(adapters.Select(a => a.Handle));
                        adapters = GetAdapters();
                        refreshed = DateTime.UtcNow;
                    }

                    double? cpu = ReadCpu();
                    double? gpu = null; string kind = "", name = "";
                    foreach (var a in adapters.OrderBy(a => a.Integrated))
                    {
                        int t = Kmt.TempDeci(a.Handle);
                        if (t > 0 && t < 1500) { gpu = t / 10.0; kind = a.Integrated ? "iGPU" : "dGPU"; name = a.Name; break; }
                    }
                    if (gpu == null && cpu != null)
                    {
                        var ig = adapters.FirstOrDefault(a => a.Integrated);
                        if (ig != null) { gpu = cpu; kind = "iGPU"; name = ig.Name + " (shares CPU die)"; }
                    }

                    if (once)
                    {
                        var lines = adapters.Select(a => string.Format("{0,-45} integrated={1} temp={2}", a.Name, a.Integrated, Kmt.TempDeci(a.Handle) / 10.0)).ToList();
                        lines.Add("Thermal zones: " + string.Join(", ", zones.Select(z => z.Key)));
                        lines.Add(string.Format("CPU={0}  GPU={1} ({2} {3})", F(cpu), F(gpu), kind, name));
                        File.WriteAllLines(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "KerfSensors.log"), lines);
                        break;
                    }

                    if (cpu.HasValue) lastCpu = cpu;
                    if (gpu.HasValue) { lastGpu = gpu; lastKind = kind; lastName = name; }
                    key.SetValue("CPU", F(lastCpu));
                    key.SetValue("GPU", F(lastGpu));
                    key.SetValue("GPUKind", lastKind);
                    key.SetValue("GPUName", lastName);
                    key.SetValue("Tick", DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString());
                }

                if (Process.GetProcessesByName("Rainmeter").Length == 0) break;
                Thread.Sleep(1000);
            }
            Kmt.Close(adapters.Select(a => a.Handle));
            key.Close();
        }
    }
}
