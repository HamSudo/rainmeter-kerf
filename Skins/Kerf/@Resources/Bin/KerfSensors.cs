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

static class Backdrop
{
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L, T, R, B; }
    [StructLayout(LayoutKind.Sequential)] struct POINT { public int X, Y; }
    delegate bool EnumProc(IntPtr h, IntPtr l);
    [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc f, IntPtr l);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetWindowText(IntPtr h, System.Text.StringBuilder s, int n);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr h, System.Text.StringBuilder s, int n);
    [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] static extern IntPtr WindowFromPoint(POINT p);
    [DllImport("user32.dll")] static extern IntPtr GetAncestor(IntPtr h, uint flags);
    [DllImport("user32.dll")] static extern int GetSystemMetrics(int i);
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();

    public static Dictionary<string, RECT> Modules()
    {
        var d = new Dictionary<string, RECT>();
        EnumWindows((h, l) =>
        {
            if (!IsWindowVisible(h)) return true;
            var sb = new System.Text.StringBuilder(512); GetWindowText(h, sb, 512);
            string t = sb.ToString();
            int i = t.IndexOf(@"\Kerf\", StringComparison.OrdinalIgnoreCase);
            if (i >= 0 && t.EndsWith(".ini", StringComparison.OrdinalIgnoreCase))
            {
                string rest = t.Substring(i + 6);
                int j = rest.IndexOf('\\');
                if (j > 0 && rest.Substring(0, j) != "Settings") { RECT r; GetWindowRect(h, out r); d[rest.Substring(0, j)] = r; }
            }
            return true;
        }, IntPtr.Zero);
        return d;
    }

    static bool Desktop(int x, int y)
    {
        IntPtr h = WindowFromPoint(new POINT { X = x, Y = y });
        if (h == IntPtr.Zero) return false;
        var sb = new System.Text.StringBuilder(256); GetClassName(GetAncestor(h, 2), sb, 256);
        string c = sb.ToString();
        return c == "Progman" || c == "WorkerW" || c == "RainmeterMeterWindow";
    }

    public static bool Visible(RECT r)
    {
        int seen = 0, total = 0;
        for (int gy = 1; gy <= 3; gy++)
            for (int gx = 1; gx <= 3; gx++)
            {
                total++;
                if (Desktop(r.L + (r.R - r.L) * gx / 4, r.T + (r.B - r.T) * gy / 4)) seen++;
            }
        return seen * 2 > total;
    }

    public static string WallpaperSignature()
    {
        string s = "";
        try
        {
            using (var k = Registry.CurrentUser.OpenSubKey(@"Control Panel\Desktop")) s += Convert.ToString(k.GetValue("WallPaper", ""));
            using (var k = Registry.CurrentUser.OpenSubKey(@"Control Panel\Colors")) s += "|" + Convert.ToString(k.GetValue("Background", ""));
            string t = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), @"Microsoft\Windows\Themes\TranscodedWallpaper");
            if (File.Exists(t)) s += "|" + File.GetLastWriteTimeUtc(t).Ticks;
        }
        catch { }
        return s;
    }

    static double Lin(int v) { double c = v / 255.0; return c <= 0.04045 ? c / 12.92 : Math.Pow((c + 0.055) / 1.055, 2.4); }

    public static string InkArea(string module)
    {
        try { return File.ReadAllText(Path.Combine(Path.GetTempPath(), "Kerf-" + module + ".ink")).Trim(); }
        catch { return ""; }
    }

    public static RECT Area(RECT r, string spec, out bool exact)
    {
        exact = false;
        var p = spec.Split(' ');
        var v = new double[6];
        if (p.Length != 6) return r;
        for (int i = 0; i < 6; i++)
            if (!double.TryParse(p[i], System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture, out v[i])) return r;
        if (v[4] <= 0 || v[5] <= 0 || v[2] <= v[0] || v[3] <= v[1]) return r;
        double sx = (r.R - r.L) / v[4], sy = (r.B - r.T) / v[5];
        exact = true;
        return new RECT
        {
            L = r.L + (int)Math.Floor(v[0] * sx) - 3,
            T = r.T + (int)Math.Floor(v[1] * sy) - 3,
            R = r.L + (int)Math.Ceiling(v[2] * sx) + 3,
            B = r.T + (int)Math.Ceiling(v[3] * sy) + 3
        };
    }

    const double InkLight = 0.92, InkDark = 0.0077;

    public static double[] Reading(RECT r, int m)
    {
        int vx = GetSystemMetrics(76), vy = GetSystemMetrics(77), vw = GetSystemMetrics(78), vh = GetSystemMetrics(79);
        int x0 = Math.Max(vx, r.L - m), y0 = Math.Max(vy, r.T - m);
        int x1 = Math.Min(vx + vw, r.R + m), y1 = Math.Min(vy + vh, r.B + m);
        int w = x1 - x0, h = y1 - y0;
        if (w < 4 || h < 4) return null;
        try
        {
            using (var bmp = new System.Drawing.Bitmap(w, h))
            using (var g = System.Drawing.Graphics.FromImage(bmp))
            {
                g.CopyFromScreen(x0, y0, 0, 0, new System.Drawing.Size(w, h));
                var vals = new List<double>();
                int total = 0, cols = 20, rows = 12;
                for (int gy = 0; gy < rows; gy++)
                    for (int gx = 0; gx < cols; gx++)
                    {
                        int px = (int)((gx + 0.5) * w / cols), py = (int)((gy + 0.5) * h / rows);
                        total++;
                        if (!Desktop(x0 + px, y0 + py)) continue;
                        var c = bmp.GetPixel(px, py);
                        vals.Add(0.2126 * Lin(c.R) + 0.7152 * Lin(c.G) + 0.0722 * Lin(c.B));
                    }
                if (vals.Count < total / 2) return null;
                vals.Sort();
                double lo = vals[(int)(0.15 * (vals.Count - 1))], hi = vals[(int)(0.85 * (vals.Count - 1))];
                double eff = Math.Sqrt((lo + 0.05) * (hi + 0.05)) - 0.05;
                double light = (InkLight + 0.05) / (hi + 0.05), dark = (lo + 0.05) / (InkDark + 0.05);
                return new[] { eff, Math.Max(light, dark) };
            }
        }
        catch { return null; }
    }
}

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
        bool owned;
        using (var mutex = new Mutex(true, @"Local\KerfSensors", out owned))
        {
            if (!owned) return;

            Backdrop.SetProcessDPIAware();
            var adapters = GetAdapters();
            DateTime refreshed = DateTime.UtcNow;
            RegistryKey key = Registry.CurrentUser.CreateSubKey(@"Software\Kerf\Sensors");
            RegistryKey ink = Registry.CurrentUser.CreateSubKey(@"Software\Kerf\Ink");
            double? lastCpu = null, lastGpu = null, lastIgpu = null, lastDgpu = null; string lastKind = "", lastName = "";
            string lastLayout = null, lastWall = null;
            DateTime lastSample = DateTime.MinValue, lastTemps = DateTime.MinValue;
            bool wasVisible = false;
            var inv = System.Globalization.CultureInfo.InvariantCulture;

            while (true)
            {
                string now = DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString();
                var mods = Backdrop.Modules();

                bool visible = mods.Values.Any(Backdrop.Visible);
                bool shown = visible && !wasVisible;
                wasVisible = visible;
                ink.SetValue("Visible", visible ? "1" : "0");
                ink.SetValue("Alive", now);

                if (visible)
                {

                    var areas = mods.Keys.ToDictionary(k => k, k => Backdrop.InkArea(k));
                    string layout = string.Join(";", mods.OrderBy(m => m.Key).Select(m => m.Key + ":" + m.Value.L + "," + m.Value.T + "," + m.Value.R + "," + m.Value.B + "|" + areas[m.Key]));
                    string wall = Backdrop.WallpaperSignature();
                    double recheck = 10;
                    double.TryParse(Convert.ToString(ink.GetValue("InkRecheckMinutes", "10")), System.Globalization.NumberStyles.Float, inv, out recheck);
                    bool due = recheck > 0 && (DateTime.UtcNow - lastSample).TotalMinutes >= recheck;
                    if (mods.Count > 0 && (shown || layout != lastLayout || wall != lastWall || due))
                    {
                        var readings = new Dictionary<string, List<double[]>>();
                        for (int r = 0; r < 3; r++)
                        {
                            if (r > 0) Thread.Sleep(1500);
                            foreach (var mod in mods)
                            {
                                bool exact;
                                var area = Backdrop.Area(mod.Value, areas[mod.Key], out exact);
                                var rd = Backdrop.Reading(area, exact ? 0 : 12);
                                if (rd == null) continue;
                                if (!readings.ContainsKey(mod.Key)) readings[mod.Key] = new List<double[]>();
                                readings[mod.Key].Add(rd);
                            }
                        }
                        foreach (var rd in readings)
                        {
                            var mid = rd.Value.OrderBy(v => v[0]).ElementAt(rd.Value.Count / 2);
                            ink.SetValue(rd.Key, mid[0].ToString("0.000", inv));
                            ink.SetValue(rd.Key + "C", mid[1].ToString("0.00", inv));
                        }
                        if (readings.Count > 0) ink.SetValue("Tick", DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString());
                        lastLayout = layout; lastWall = wall; lastSample = DateTime.UtcNow;
                    }

                    if (shown || (DateTime.UtcNow - lastTemps).TotalSeconds >= 10)
                    {
                        lastTemps = DateTime.UtcNow;
                        if ((DateTime.UtcNow - refreshed).TotalSeconds > 60)
                        {
                            Kmt.Close(adapters.Select(a => a.Handle));
                            adapters = GetAdapters();
                            refreshed = DateTime.UtcNow;
                        }

                        double? cpu = ReadCpu();
                        double? igpu = null, dgpu = null;
                        foreach (var a in adapters)
                        {
                            int t = Kmt.TempDeci(a.Handle);
                            if (t <= 0 || t >= 1500) continue;
                            if (a.Integrated) { if (igpu == null) igpu = t / 10.0; }
                            else if (dgpu == null) { dgpu = t / 10.0; lastName = a.Name; }
                        }
                        if (igpu == null && cpu != null && adapters.Any(a => a.Integrated)) igpu = cpu;

                        double? gpu = dgpu ?? igpu;
                        string kind = dgpu != null ? "dGPU" : igpu != null ? "iGPU" : "";

                        if (cpu.HasValue) lastCpu = cpu;
                        if (gpu.HasValue) { lastGpu = gpu; lastKind = kind; }
                        if (igpu.HasValue) lastIgpu = igpu;
                        if (dgpu.HasValue) lastDgpu = dgpu;
                        key.SetValue("CPU", F(lastCpu));
                        key.SetValue("GPU", F(lastGpu));
                        key.SetValue("GPUKind", lastKind);
                        key.SetValue("GPUName", lastName);
                        key.SetValue("iGPU", F(lastIgpu));
                        key.SetValue("dGPU", F(lastDgpu));
                        key.SetValue("Tick", DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString());
                    }
                }

                if (Process.GetProcessesByName("Rainmeter").Length == 0) break;
                Thread.Sleep(1000);
            }
            Kmt.Close(adapters.Select(a => a.Handle));
            key.Close();
            ink.Close();
        }
    }
}
