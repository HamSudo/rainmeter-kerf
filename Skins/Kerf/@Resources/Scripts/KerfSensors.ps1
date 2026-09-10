param([switch]$Once)
$ErrorActionPreference = 'SilentlyContinue'

$created = $false
$mutex = New-Object System.Threading.Mutex($true, 'Local\KerfSensors', [ref]$created)
if (-not $Once -and -not $created) { exit }

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class KerfKmt {
    [StructLayout(LayoutKind.Sequential)] struct ADAPTERINFO { public uint hAdapter; public uint LuidLow; public int LuidHigh; public uint NumOfSources; public int Precise; }
    [StructLayout(LayoutKind.Sequential)] struct ENUM2 { public uint NumAdapters; public IntPtr pAdapters; }
    [StructLayout(LayoutKind.Sequential)] struct QUERY { public uint hAdapter; public int Type; public IntPtr pData; public uint Size; }
    [StructLayout(LayoutKind.Sequential)] struct CLOSE { public uint hAdapter; }

    [DllImport("gdi32.dll")] static extern int D3DKMTEnumAdapters2(ref ENUM2 e);
    [DllImport("gdi32.dll")] static extern int D3DKMTQueryAdapterInfo(ref QUERY q);
    [DllImport("gdi32.dll")] static extern int D3DKMTCloseAdapter(ref CLOSE c);

    const int ADAPTERREGISTRYINFO = 8, ADAPTERTYPE = 15, ADAPTERPERFDATA = 62;

    public static uint[] Open() {
        var e = new ENUM2();
        if (D3DKMTEnumAdapters2(ref e) != 0 || e.NumAdapters == 0) return new uint[0];
        int sz = Marshal.SizeOf(typeof(ADAPTERINFO));
        e.pAdapters = Marshal.AllocHGlobal(sz * (int)e.NumAdapters);
        try {
            if (D3DKMTEnumAdapters2(ref e) != 0) return new uint[0];
            var r = new uint[e.NumAdapters];
            for (int i = 0; i < r.Length; i++)
                r[i] = ((ADAPTERINFO)Marshal.PtrToStructure(new IntPtr(e.pAdapters.ToInt64() + i * sz), typeof(ADAPTERINFO))).hAdapter;
            return r;
        } finally { Marshal.FreeHGlobal(e.pAdapters); }
    }

    public static void Close(uint[] handles) {
        foreach (var h in handles) { var c = new CLOSE { hAdapter = h }; D3DKMTCloseAdapter(ref c); }
    }

    static int Query(uint h, int type, IntPtr buf, int size) {
        var zero = new byte[size]; Marshal.Copy(zero, 0, buf, size);
        var q = new QUERY { hAdapter = h, Type = type, pData = buf, Size = (uint)size };
        return D3DKMTQueryAdapterInfo(ref q);
    }

    public static string Name(uint h) {
        int size = 260 * 2 * 4; IntPtr b = Marshal.AllocHGlobal(size);
        try { return Query(h, ADAPTERREGISTRYINFO, b, size) == 0 ? Marshal.PtrToStringUni(b) : ""; }
        finally { Marshal.FreeHGlobal(b); }
    }

    public static uint Flags(uint h) {
        IntPtr b = Marshal.AllocHGlobal(4);
        try { return Query(h, ADAPTERTYPE, b, 4) == 0 ? (uint)Marshal.ReadInt32(b) : 0; }
        finally { Marshal.FreeHGlobal(b); }
    }

    public static int TempDeci(uint h) {
        int size = 64; IntPtr b = Marshal.AllocHGlobal(size);
        try { return Query(h, ADAPTERPERFDATA, b, size) == 0 ? Marshal.ReadInt32(b, 56) : -1; }
        finally { Marshal.FreeHGlobal(b); }
    }
}
'@

$discreteRx   = 'nvidia|geforce|rtx|gtx|quadro|radeon rx|radeon pro|\brx \d|arc a\d|arc b\d'
$integratedRx = 'uhd|iris|intel\(r\) hd|intel hd|radeon\(tm\) graphics|radeon graphics|vega \d+ graphics|arc\(tm\) graphics|arc graphics'

function Get-Adapters {
    $list = @()
    foreach ($h in [KerfKmt]::Open()) {
        $flags = [KerfKmt]::Flags($h)
        if ($flags -band 4) { continue }                      # Microsoft Basic Render Driver etc.
        $name = [KerfKmt]::Name($h)
        $integrated = (($flags -band 32) -ne 0) -or ($name -match $integratedRx)
        $discrete   = (($flags -band 16) -ne 0) -or (($flags -band 1024) -ne 0) -or ($name -match $discreteRx)
        if ($discrete) { $integrated = $false }
        $list += [pscustomobject]@{ Handle = $h; Name = $name; Integrated = $integrated }
    }
    $list
}

function Read-Gpu($adapters) {
    foreach ($a in ($adapters | Sort-Object Integrated)) {
        $t = [KerfKmt]::TempDeci($a.Handle)
        if ($t -gt 0 -and $t -lt 1500) {
            return [pscustomobject]@{ Temp = [math]::Round($t / 10, 1); Kind = $(if ($a.Integrated) { 'iGPU' } else { 'dGPU' }); Name = $a.Name }
        }
    }
    [pscustomobject]@{ Temp = ''; Kind = ''; Name = '' }
}

$zones = $null
function Read-Cpu {
    if (-not $script:zones) {
        $cat = New-Object System.Diagnostics.PerformanceCounterCategory('Thermal Zone Information')
        $names = $cat.GetInstanceNames()
        $counter = if ($cat.CounterExists('High Precision Temperature')) { 'High Precision Temperature' } else { 'Temperature' }
        $script:zones = foreach ($n in $names) {
            [pscustomobject]@{ Name = $n; Counter = New-Object System.Diagnostics.PerformanceCounter('Thermal Zone Information', $counter, $n, $true); Tenths = ($counter -like 'High*') }
        }
    }
    $best = $null
    foreach ($z in $script:zones) {
        $raw = $z.Counter.NextValue()
        $k = if ($z.Tenths) { $raw / 10 } else { $raw }
        $c = [math]::Round($k - 273.15, 1)
        if ($c -le 5 -or $c -ge 125) { continue }
        if ($z.Name -match 'cpu') { return $c }                # a zone named for the CPU wins
        if ($null -eq $best -or $c -gt $best) { $best = $c }
    }
    if ($null -eq $best) { '' } else { $best }
}

$key = 'HKCU:\Software\Kerf\Sensors'
New-Item -Path $key -Force | Out-Null
$adapters = Get-Adapters
$refresh = [datetime]::Now

while ($true) {
    if (([datetime]::Now - $refresh).TotalSeconds -gt 60) {   # pick up eGPU plug/unplug, driver resets
        [KerfKmt]::Close(@($adapters | ForEach-Object Handle)); $adapters = Get-Adapters; $refresh = [datetime]::Now
    }
    $gpu = Read-Gpu $adapters
    $cpu = Read-Cpu
    if ($gpu.Temp -eq '' -and $cpu -ne '' -and ($adapters | Where-Object Integrated)) {
        $ig = $adapters | Where-Object Integrated | Select-Object -First 1
        $gpu = [pscustomobject]@{ Temp = $cpu; Kind = 'iGPU'; Name = "$($ig.Name) (shares CPU die)" }
    }
    if ($Once) {
        $adapters | ForEach-Object { '{0,-45} integrated={1} temp={2}' -f $_.Name, $_.Integrated, ([KerfKmt]::TempDeci($_.Handle) / 10) }
        'Thermal zones: ' + (($script:zones | ForEach-Object Name) -join ', ')
        "CPU=$cpu  GPU=$($gpu.Temp) ($($gpu.Kind) $($gpu.Name))"
        break
    }
    Set-ItemProperty -Path $key -Name CPU -Value "$cpu"
    Set-ItemProperty -Path $key -Name GPU -Value "$($gpu.Temp)"
    Set-ItemProperty -Path $key -Name GPUKind -Value $gpu.Kind
    Set-ItemProperty -Path $key -Name GPUName -Value $gpu.Name
    Set-ItemProperty -Path $key -Name Tick -Value ([string][DateTimeOffset]::UtcNow.ToUnixTimeSeconds())
    if (-not (Get-Process -Name Rainmeter)) { break }
    Start-Sleep -Seconds 2
}
[KerfKmt]::Close(@($adapters | ForEach-Object Handle))
