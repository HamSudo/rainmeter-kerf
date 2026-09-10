# Kerf

A modular Rainmeter skin: a clock with a music line, and CPU and GPU
temperatures read straight from Windows -- no HWiNFO, no extra software.

## Install

Download `Kerf-0.1.0.rmskin` from the release and double-click it.
Rainmeter installs the skin and the Chameleon plugin it needs.

## Modules

- **Clock** -- time, seconds, a music waveform, the day and the date, all as
  one movable unit.
- **CPU** and **GPU** -- temperature, with a small scale underneath.

## Adaptive ink

Kerf reads whatever is behind it -- a Wallpaper Engine wallpaper, a solid
colour or a Windows wallpaper -- and switches between light and dark ink. Set
it by hand from the right-click menu (Ink: auto / always light / always dark).

## Alignment

Right-click any module to align it to the left edge, the centre or the right
edge of its monitor, or leave it on "follow position", where it stays where
you drop it and its text follows the third of the screen it sits in.

## Fonts

The fonts Kerf uses are bundled in `Skins\Kerf\@Resources\Fonts` and are
loaded by Rainmeter itself, so nothing has to be installed.

To use a font of your own, drop its `.ttf` or `.otf` files into that folder
and add the family name to `FONTS` in
`Skins\Kerf\@Resources\Scripts\Settings.lua`. A font already installed on
the machine works too -- only the family name matters.

## Sensors

`@Resources\Bin\KerfSensors.cs` is a small helper that reads the CPU's
thermal zone and the GPU's D3DKMT performance data -- the same numbers Task
Manager shows. Rainmeter compiles it with the C# compiler that ships with
Windows the first time it is needed.

## Licence

MIT. Bundled fonts are under the SIL Open Font License; the Chameleon plugin
is BSD-3.
