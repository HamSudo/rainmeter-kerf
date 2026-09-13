using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Threading;
using Windows.Foundation;
using Windows.Media.Control;
using Windows.Storage.Streams;
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
                int cols = 20, rows = 12, cw = 5, ch = 4;
                var open = new bool[cw, ch];
                int clear = 0;
                for (int cy = 0; cy < ch; cy++)
                    for (int cx = 0; cx < cw; cx++)
                    {
                        open[cx, cy] = Desktop(x0 + (int)((cx + 0.5) * w / cw), y0 + (int)((cy + 0.5) * h / ch));
                        if (open[cx, cy]) clear++;
                    }
                if (clear * 2 < cw * ch) return null;
                var vals = new List<double>();
                int total = 0;
                for (int gy = 0; gy < rows; gy++)
                    for (int gx = 0; gx < cols; gx++)
                    {
                        total++;
                        if (!open[gx * cw / cols, gy * ch / rows]) continue;
                        int px = (int)((gx + 0.5) * w / cols), py = (int)((gy + 0.5) * h / rows);
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

// The Windows media session: whatever is playing, from the same place the
// volume flyout reads it -- a browser tab, Spotify, a local player, anything
// that registers with the system transport controls.
static class Media
{
    const int Size = 192;
    const string SEP = "\u0001";
    static readonly DateTime Epoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
    static double Now() { return (DateTime.UtcNow - Epoch).TotalSeconds; }

    // WinRT's async operations are awaited by hand: this runs on its own MTA
    // thread, so the completion handler lands on the pool and a plain wait is
    // enough -- no message pump, and no projection assembly to reference.
    static T Await<T>(IAsyncOperation<T> op, int ms)
    {
        if (op == null) return default(T);
        using (var done = new ManualResetEventSlim(false))
        {
            op.Completed = (o, s) => done.Set();
            if (!done.Wait(ms) || op.Status != AsyncStatus.Completed) return default(T);
            return op.GetResults();
        }
    }

    // the ink loop already knows whether the desktop is covered; when it is,
    // nobody can see the card, so ask the session less often
    public static volatile bool Awake = true;

    // the artwork the skin is pointed at, so the sweep leaves it alone
    static string curArt = "", curDisc = "";

    public static void Start()
    {
        try
        {
            var t = new Thread(Loop);
            t.IsBackground = true;
            t.SetApartmentState(ApartmentState.MTA);
            t.Start();
        }
        catch { }
    }

    static void Loop()
    {
        RegistryKey key;
        try { key = Registry.CurrentUser.CreateSubKey(@"Software\Kerf\Media"); }
        catch { return; }
        GlobalSystemMediaTransportControlsSessionManager mgr = null;
        string artKey = null;
        DateTime swept = DateTime.MinValue;
        while (true)
        {
            try { mgr = Poll(key, mgr, ref artKey); }
            catch { mgr = null; }
            if ((DateTime.UtcNow - swept).TotalSeconds >= 30)
            {
                swept = DateTime.UtcNow;
                Sweep();
            }
            if (Process.GetProcessesByName("Rainmeter").Length == 0) break;
            Thread.Sleep(Awake ? 1000 : 3000);
        }
        try { key.Close(); } catch { }
    }

    static void Write(RegistryKey key, string app, string title, string artist, int status, double pos, double len)
    {
        var inv = System.Globalization.CultureInfo.InvariantCulture;
        key.SetValue("App", app);
        key.SetValue("Title", title);
        key.SetValue("Artist", artist);
        key.SetValue("Status", status.ToString(inv));
        key.SetValue("Pos", pos.ToString("0.000", inv));
        key.SetValue("Len", len.ToString("0.000", inv));
        key.SetValue("PosAt", Now().ToString("0.000", inv));
        key.SetValue("Tick", ((long)Now()).ToString(inv));
    }

    static void Quiet(RegistryKey key, ref string artKey)
    {
        if (artKey != null)
        {
            artKey = null;
            curArt = ""; curDisc = "";
            key.SetValue("Art", "");
            key.SetValue("Disc", "");
        }
        Write(key, "", "", "", 0, 0, 0);
    }

    static GlobalSystemMediaTransportControlsSessionManager Poll(
        RegistryKey key, GlobalSystemMediaTransportControlsSessionManager mgr, ref string artKey)
    {
        if (mgr == null) mgr = Await(GlobalSystemMediaTransportControlsSessionManager.RequestAsync(), 5000);
        if (mgr == null) { Quiet(key, ref artKey); return null; }

        var s = mgr.GetCurrentSession();
        if (s == null) { Quiet(key, ref artKey); return mgr; }

        var p = Await(s.TryGetMediaPropertiesAsync(), 3000);
        string title = p != null ? (p.Title ?? "") : "";
        string album = p != null ? (p.AlbumTitle ?? "") : "";
        string artist = p != null ? (p.Artist ?? "") : "";
        if (artist.Length == 0) artist = album;

        int status;
        switch (s.GetPlaybackInfo().PlaybackStatus)
        {
            case GlobalSystemMediaTransportControlsSessionPlaybackStatus.Playing: status = 1; break;
            case GlobalSystemMediaTransportControlsSessionPlaybackStatus.Paused: status = 2; break;
            default: status = 0; break;
        }

        var t = s.GetTimelineProperties();
        double pos = (t.Position - t.StartTime).TotalSeconds;
        double len = (t.EndTime - t.StartTime).TotalSeconds;
        if (pos < 0 || double.IsNaN(pos)) pos = 0;
        if (len < 0 || double.IsNaN(len) || len > 86400) len = 0;
        if (len > 0 && pos > len) pos = len;

        // the artwork only has to be redrawn when the track itself changes
        string want = title + SEP + artist + SEP + album + SEP + s.SourceAppUserModelId;
        if (want != artKey)
        {
            artKey = want;
            string art = "", disc = "";
            try
            {
                byte[] raw = Thumb(p);
                if (raw != null) Render(raw, out art, out disc);
            }
            catch { art = ""; disc = ""; }
            curArt = art; curDisc = disc;
            key.SetValue("Art", art);
            key.SetValue("Disc", disc);
        }

        Write(key, s.SourceAppUserModelId ?? "", title, artist, status, pos, len);
        return mgr;
    }

    static byte[] Thumb(GlobalSystemMediaTransportControlsSessionMediaProperties p)
    {
        if (p == null || p.Thumbnail == null) return null;
        var st = Await(p.Thumbnail.OpenReadAsync(), 4000);
        if (st == null || st.Size == 0 || st.Size > 8 * 1024 * 1024) return null;
        var rd = new DataReader(st.GetInputStreamAt(0));
        uint n = Await(rd.LoadAsync((uint)st.Size), 4000);
        if (n == 0) return null;
        var buf = new byte[n];
        rd.ReadBytes(buf);
        return buf;
    }

    // Rainmeter caches an image against its path, so every cover is written
    // under a name of its own and the stale ones are swept up behind it
    static void Render(byte[] raw, out string art, out string disc)
    {
        art = ""; disc = "";
        string stamp = ((long)(Now() * 1000)).ToString(System.Globalization.CultureInfo.InvariantCulture);
        string dir = Path.GetTempPath();
        string a = Path.Combine(dir, "Kerf-art-" + stamp + ".png");
        string d = Path.Combine(dir, "Kerf-disc-" + stamp + ".png");
        using (var ms = new MemoryStream(raw))
        using (var src = new System.Drawing.Bitmap(ms))
        using (var square = Square(src))
        {
            square.Save(a, System.Drawing.Imaging.ImageFormat.Png);
            using (var ring = Disc(square)) ring.Save(d, System.Drawing.Imaging.ImageFormat.Png);
        }
        art = a; disc = d;
    }

    static System.Drawing.Bitmap Square(System.Drawing.Image src)
    {
        int side = Math.Min(src.Width, src.Height);
        var crop = new System.Drawing.Rectangle((src.Width - side) / 2, (src.Height - side) / 2, side, side);
        var bmp = new System.Drawing.Bitmap(Size, Size, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
        using (var g = System.Drawing.Graphics.FromImage(bmp))
        {
            g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
            g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;
            g.DrawImage(src, new System.Drawing.Rectangle(0, 0, Size, Size), crop, System.Drawing.GraphicsUnit.Pixel);
        }
        return bmp;
    }

    // the same cover as a record: round, with the spindle hole punched out, so
    // the skin only has to turn it
    static System.Drawing.Bitmap Disc(System.Drawing.Image square)
    {
        float d = Size;                  // the record fills its canvas
        float o = 0f;
        float hole = d * 0.17f;
        float hx = (Size - hole) / 2f;
        var bmp = new System.Drawing.Bitmap(Size, Size, System.Drawing.Imaging.PixelFormat.Format32bppArgb);
        using (var g = System.Drawing.Graphics.FromImage(bmp))
        {
            g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
            g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
            using (var path = new System.Drawing.Drawing2D.GraphicsPath())
            {
                path.AddEllipse(o, o, d, d);
                path.AddEllipse(hx, hx, hole, hole);
                using (var region = new System.Drawing.Region(path))
                {
                    g.Clip = region;
                    g.DrawImage(square, o, o, d, d);
                }
            }
            g.ResetClip();
            using (var pen = new System.Drawing.Pen(System.Drawing.Color.FromArgb(80, 0, 0, 0), d * 0.016f))
                g.DrawEllipse(pen, o + d * 0.008f, o + d * 0.008f, d * 0.984f, d * 0.984f);
            using (var pen = new System.Drawing.Pen(System.Drawing.Color.FromArgb(46, 255, 255, 255), d * 0.006f))
                g.DrawEllipse(pen, o + d * 0.295f, o + d * 0.295f, d * 0.41f, d * 0.41f);
            using (var pen = new System.Drawing.Pen(System.Drawing.Color.FromArgb(96, 0, 0, 0), d * 0.012f))
                g.DrawEllipse(pen, hx, hx, hole, hole);
        }
        return bmp;
    }

    static void Sweep()
    {
        try
        {
            var dir = new DirectoryInfo(Path.GetTempPath());
            foreach (var f in dir.GetFiles("Kerf-art-*.png").Concat(dir.GetFiles("Kerf-disc-*.png")))
            {
                // whatever is on screen stays, however long the track has run
                if (f.FullName.Equals(curArt, StringComparison.OrdinalIgnoreCase)) continue;
                if (f.FullName.Equals(curDisc, StringComparison.OrdinalIgnoreCase)) continue;
                if ((DateTime.UtcNow - f.LastWriteTimeUtc).TotalMinutes > 2)
                    try { f.Delete(); } catch { }
            }
        }
        catch { }
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
            Media.Start();
            var adapters = GetAdapters();
            DateTime refreshed = DateTime.UtcNow;
            RegistryKey key = Registry.CurrentUser.CreateSubKey(@"Software\Kerf\Sensors");
            RegistryKey ink = Registry.CurrentUser.CreateSubKey(@"Software\Kerf\Ink");
            double? lastCpu = null, lastGpu = null, lastIgpu = null, lastDgpu = null; string lastKind = "", lastName = "";
            string lastLayout = null, lastWall = null;
            DateTime lastSample = DateTime.MinValue, lastTemps = DateTime.MinValue;
            DateTime liveUntil = DateTime.MinValue, lastWatch = DateTime.MinValue, lastLook = DateTime.MinValue;
            var lastEff = new Dictionary<string, double>();
            bool wasVisible = false;
            var inv = System.Globalization.CultureInfo.InvariantCulture;

            while (true)
            {
                string now = DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString();
                // while the desktop is covered there is nothing to read, so even the
                // "is it covered?" question is asked half as often
                bool look = wasVisible || (DateTime.UtcNow - lastLook).TotalSeconds >= 2;
                var mods = look ? Backdrop.Modules() : new Dictionary<string, Backdrop.RECT>();
                if (look) lastLook = DateTime.UtcNow;

                bool visible = mods.Values.Any(Backdrop.Visible);
                bool shown = visible && !wasVisible;
                wasVisible = visible;
                ink.SetValue("Visible", visible ? "1" : "0");
                Media.Awake = visible;
                ink.SetValue("Alive", now);

                if (visible)
                {

                    var areas = mods.Keys.ToDictionary(k => k, k => Backdrop.InkArea(k));
                    string layout = string.Join(";", mods.OrderBy(m => m.Key).Select(m => m.Key + ":" + m.Value.L + "," + m.Value.T + "," + m.Value.R + "," + m.Value.B + "|" + areas[m.Key]));
                    string wall = Backdrop.WallpaperSignature();
                    double recheck = 10;
                    double.TryParse(Convert.ToString(ink.GetValue("InkRecheckMinutes", "10")), System.Globalization.NumberStyles.Float, inv, out recheck);
                    double liveEvery = 2;
                    double.TryParse(Convert.ToString(ink.GetValue("InkLiveSeconds", "2")), System.Globalization.NumberStyles.Float, inv, out liveEvery);
                    string liveMode = Convert.ToString(ink.GetValue("InkLiveMode", "auto")).ToLowerInvariant();

                    bool changed = shown || layout != lastLayout || wall != lastWall;
                    bool due = recheck > 0 && (DateTime.UtcNow - lastSample).TotalMinutes >= recheck;
                    bool live = liveMode == "on" || (liveMode != "off" && DateTime.UtcNow < liveUntil);
                    bool soon = live && liveEvery > 0 && (DateTime.UtcNow - lastSample).TotalSeconds >= liveEvery;

                    if (mods.Count > 0 && (changed || due || soon))
                    {
                        // a moving wallpaper is sampled once a tick; a still one is averaged
                        // over three grabs, which costs nothing when it happens this rarely
                        int rounds = live && !changed ? 1 : 3;
                        var readings = new Dictionary<string, List<double[]>>();
                        for (int r = 0; r < rounds; r++)
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
                        double moved = 0;
                        foreach (var rd in readings)
                        {
                            var mid = rd.Value.OrderBy(v => v[0]).ElementAt(rd.Value.Count / 2);
                            double was;
                            if (lastEff.TryGetValue(rd.Key, out was)) moved = Math.Max(moved, Math.Abs(mid[0] - was));
                            lastEff[rd.Key] = mid[0];
                            ink.SetValue(rd.Key, mid[0].ToString("0.000", inv));
                            ink.SetValue(rd.Key + "C", mid[1].ToString("0.00", inv));
                        }
                        // the backdrop moved on its own: keep watching it for a while
                        if (moved > 0.02 && !changed) liveUntil = DateTime.UtcNow.AddSeconds(60);
                        if (readings.Count > 0) ink.SetValue("Tick", DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString());
                        lastLayout = layout; lastWall = wall; lastSample = DateTime.UtcNow;
                    }
                    else if (!live && liveMode != "off" && mods.Count > 0 && (DateTime.UtcNow - lastWatch).TotalSeconds >= 5)
                    {
                        // one cheap grab, to notice a wallpaper that moves by itself
                        lastWatch = DateTime.UtcNow;
                        var mod = mods.First();
                        bool exact;
                        var area = Backdrop.Area(mod.Value, areas[mod.Key], out exact);
                        var rd = Backdrop.Reading(area, exact ? 0 : 12);
                        double was;
                        if (rd != null && lastEff.TryGetValue(mod.Key, out was) && Math.Abs(rd[0] - was) > 0.02)
                            liveUntil = DateTime.UtcNow.AddSeconds(60);
                        if (rd != null) lastEff[mod.Key] = rd[0];
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
