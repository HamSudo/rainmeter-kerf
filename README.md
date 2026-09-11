# Kerf

A modular Rainmeter skin: a clock with a music line, and CPU and GPU
temperatures read straight from Windows -- no HWiNFO, no extra software.

## Install

Download `Kerf-0.3.0.rmskin` from the release and double-click it.

## Modules

- **Clock** -- time, seconds, a music waveform that follows what is playing,
  the day and the date.
- **CPU** and **GPU** -- temperature with a small scale underneath.

## Layouts

The clock comes in three layouts -- classic, vertical and horizontal -- and
CPU and GPU in two, horizontal and vertical. Pick them in the panel.

## Customize Kerf

Right-click any module and choose **Customize Kerf**. The panel sets, per
module, its size, transparency, what happens on hover and how it aligns; and,
for all modules at once, the accent colour, the font, the ink mode and the
display scale, and the 12- or 24-hour clock. The clock's parts (time, seconds, wave, day, date) can be shown
or hidden there too.

Kerf replaces Rainmeter's own Transparency and On-hover settings. If you use
them from Rainmeter's menu, Kerf adopts the values and resets them.

## Adaptive ink

Kerf reads what is behind it -- Wallpaper Engine, a solid colour or a Windows
wallpaper -- and switches between light and dark ink.

## Fonts

The fonts Kerf uses are bundled in `Skins\Kerf\@Resources\Fonts` and are
loaded by Rainmeter itself, so nothing has to be installed.

To use a font of your own, drop its `.ttf` or `.otf` files into that folder
and add the family name to `FONTS` in
`Skins\Kerf\@Resources\Scripts\Settings.lua`. A font already installed on
the machine works too -- only the family name matters.

## Sensors

A small helper (`@Resources\Bin\KerfSensors.cs`) reads the CPU's thermal
zone and the GPU's D3DKMT performance data, the same numbers Task Manager
shows. Rainmeter compiles it with the C# compiler that ships with Windows.

## Licence

MIT. Bundled fonts are under the SIL Open Font License; the Chameleon plugin
is BSD-3.
