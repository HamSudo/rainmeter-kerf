# Kerf

A modular Rainmeter skin. A clock with a music line, plus CPU and GPU
temperatures read straight from Windows -- no HWiNFO, no extra software.

Everything is set from one panel: layouts, sizes, transparency, hover, the
accent colour, the font, the weights, the units and the alignment.

## Install

Download `Kerf-1.0.0.rmskin` from the latest release and double-click it.
Rainmeter installs the skin, the fonts and the Chameleon plugin, and loads the
clock, CPU and GPU on first run.

Requires Rainmeter 4.5 or newer on Windows 10 or 11.

## Modules

- **Clock** -- time, seconds, a music waveform, the day and the date, in a
  classic, vertical or horizontal layout.
- **CPU** and **GPU** -- temperature in Celsius or Fahrenheit, as a horizontal
  row, a vertical bar or a circular gauge. Machines with two GPUs can show the
  integrated one, the dedicated one, or both.

## Customize Kerf

Right-click any module and choose **Customize Kerf**.

- **General** -- accent colour, font, weights, ink mode, display scale, units
  and the panel's own light or dark theme.
- **Clock / CPU / GPU** -- layout, size, transparency, hover behaviour,
  alignment, and which parts of the clock are shown.

Alignment is either "Follow", where you drag the module wherever you like, or
a pinned position (an edge, the middle or a corner) with an even margin, where
the module holds its place as its contents change size.

Kerf replaces Rainmeter's own Transparency and On-hover settings. If you use
those from Rainmeter's menu, Kerf adopts the values and resets them.

## Adaptive ink

Kerf reads what is behind each module -- a Wallpaper Engine wallpaper, a solid
colour or a Windows wallpaper -- and picks light or dark ink by contrast,
adding a shadow only where it is needed. You can also fix the ink to light or
dark in the panel.

A still wallpaper is read when it changes, and never again until it does. A
wallpaper that moves by itself -- a video or a Wallpaper Engine scene -- is
noticed on its own and then followed every couple of seconds, smoothed over
about ten seconds so a passing bright frame cannot flip the ink, and with at
least ten seconds between flips. Either way nothing is read at all while the
desktop is covered.

Three optional values under `HKCU\Software\Kerf\Ink` tune it:
`InkLiveMode` (`auto`, `on`, `off`), `InkLiveSeconds` (default 2) and
`InkRecheckMinutes` (default 10, for still wallpapers).

## Music line

The line under the clock follows whatever is playing: its height tracks the
loudness and the Windows volume, and it glows in the accent colour on the
beat. Turn the pulse off in the panel and the line stays as a quiet rule.

## Fonts

Kerf bundles fifteen display and mono families (SIL Open Font License) in
`Skins\Kerf\@Resources\Fonts`. Rainmeter loads them from that folder, so
none of them has to be installed on the machine, and the font picker in the
panel lists them all.

To add your own:

1. Drop the font's `.ttf` or `.otf` files into
   `Skins\Kerf\@Resources\Fonts`. Include the weights you want -- Kerf uses
   light (300), regular (400) and bold (700) where a family has them.
2. Add the family name to `FONTS` in
   `Skins\Kerf\@Resources\Scripts\Settings.lua`.
3. Refresh Kerf (right-click > Refresh all Kerf modules).

A family already installed on the machine works the same way -- only the name
in `FONTS` matters. Fonts whose digits sit oddly in the vertical layout can be
given their own metrics in `FONT_METRICS` in the same file.

## Sensors

`@Resources\Bin\KerfSensors.cs` is a small helper that reads the CPU's
thermal zone and the GPU's D3DKMT performance data -- the same numbers Task
Manager shows. Rainmeter builds it with the C# compiler that ships with
Windows and keeps it running while Rainmeter is open; it writes its readings
to `HKCU\Software\Kerf`.

## Build from source

```
python tools/build-rmskin.py 1.0.0
```

writes `dist/Kerf-1.0.0.rmskin`: the skin, the compiled helper and the
Chameleon plugin, packed the way Rainmeter's installer expects.

The `.ini` and `.inc` files are UTF-16 in a checkout (Rainmeter requires it)
and UTF-8 in the repository -- see `.gitattributes`.

## Credits

- Chameleon plugin by Kaelri / Charles Nikkel (BSD-3), for reading the
  wallpaper.
- Bundled fonts by their respective authors under the SIL Open Font License;
  see `THIRD-PARTY-NOTICES.md`.

## Licence

MIT -- see `LICENSE`.
