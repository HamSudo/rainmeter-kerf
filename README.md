# Kerf

[![CI](https://github.com/HamSudo/rainmeter-kerf/actions/workflows/ci.yml/badge.svg)](https://github.com/HamSudo/rainmeter-kerf/actions/workflows/ci.yml)

A modular Rainmeter skin. A clock with a music line, a card for whatever is
playing, plus CPU and GPU temperatures read straight from Windows -- no
HWiNFO, no extra software.

Everything is set from one panel: layouts, sizes, transparency, hover, the
accent colour, the font, the weights, the units and the alignment.

## Install

Download the `.rmskin` from the [latest release](https://github.com/HamSudo/rainmeter-kerf/releases/latest)
and double-click it.
Rainmeter installs the skin, the fonts and the Chameleon plugin, and loads the
clock, CPU and GPU on first run.

Requires Rainmeter 4.5 or newer on Windows 10 or 11.

## Modules

- **Clock** -- time, seconds, a music waveform, the day and the date, in a
  classic, vertical or horizontal layout.
- **Media** -- a compact card for whatever is playing: the cover, the track,
  the artist, the music line and a progress bar, in one horizontal row with a
  rule between the cover and the rest.
- **CPU** and **GPU** -- temperature in Celsius or Fahrenheit, as a horizontal
  row, a vertical bar or a circular gauge. Machines with two GPUs can show the
  integrated one, the dedicated one, or both.

## Customize Kerf

Right-click any module and choose **Customize Kerf**.

- **General** -- accent colour, font, weights, ink mode, display scale, units
  and the panel's own light or dark theme.
- **Clock / Media / CPU / GPU** -- layout, size, transparency, hover
  behaviour, alignment, and which parts are shown. The Media tab also chooses
  between a square cover and a spinning disc.

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

## Now playing

The Media card reads the Windows media session -- the same one behind the
volume flyout -- so it follows whatever registers with it: a browser tab,
Spotify, a local player. Nothing has to be installed and no player-specific
plugin is involved.

The cover is drawn either as a square or as a disc that turns while the track
plays and coasts to a stop when it is paused. Kerf cuts the disc itself, hole
and all, from the artwork the session hands over. A track with no artwork gets
a quiet placeholder instead, and when nothing is playing the card says so.

Cover, title, artist, pulse and progress bar can each be turned off in the
panel; the rows close up over whatever is hidden. A live stream has no end, so
it shows the elapsed time on its own rather than a progress bar that could
never fill.

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
Manager shows -- and the Windows media session. Rainmeter builds it with the
C# compiler that ships with Windows and keeps it running while Rainmeter is
open; it writes its readings to `HKCU\Software\Kerf`, and the cover art to
`%TEMP%` as `Kerf-art-*.png` and `Kerf-disc-*.png`, sweeping up the stale ones
behind it.

The media half is WinRT, compiled against the metadata in
`%WINDIR%\System32\WinMetadata` and the `System.Runtime` facade from the GAC.
Both ship with Windows 10 and 11, so no SDK is needed to build the helper.

## Build from source

```
python tools/build-rmskin.py 1.0.0
```

writes `dist/Kerf-1.0.0.rmskin`: the skin, the compiled helper and the
Chameleon plugin, packed the way Rainmeter's installer expects.

The `.ini` and `.inc` files are UTF-16 in a checkout (Rainmeter requires it)
and UTF-8 in the repository -- see `.gitattributes`. Edit them with something
that keeps the encoding: a tool that saves UTF-8 over one of them will load as
mojibake in Rainmeter, and `tools/check.py` fails on a missing BOM. The `.lua`
and `.cs` files are plain UTF-8 and need no such care.

`python tools/check.py` runs the static checks (needs `pip install luaparser`):
every include, script and section a skin refers to exists, the Lua parses, and
every panel button calls a function that is defined.

### Testing a working copy

The checks are static. To see a change on a real desktop, copy the skin over
an installed Kerf and let Rainmeter reload it:

```
robocopy Skins\Kerf "%USERPROFILE%\Documents\Rainmeter\Skins\Kerf" /E /R:0 /W:0 /XF *.exe Variables.inc Modules.inc
del "%USERPROFILE%\Documents\Rainmeter\Skins\Kerf\@Resources\Bin\KerfSensors.exe"
"%PROGRAMFILES%\Rainmeter\Rainmeter.exe" !RefreshApp
```

Deleting the helper matters: Rainmeter only builds `KerfSensors.exe` when it
is missing, so an old one goes on running against the new skin and the change
looks like it did nothing. `/R:0 /W:0` stops robocopy retrying for half an
hour over a font Rainmeter holds open.

The copy has to leave the installed Kerf as you have it set up:

- **`Variables.inc` and `Modules.inc` are never copied.** They hold everything
  Customize Kerf writes -- each module's layout, size, transparency, hover,
  alignment and visible parts, and the font, weights, accent and ink. Copying
  the repository's over them resets all of it to the defaults. If a change
  adds a new key to either file, add just that key to the installed file by
  hand, keeping the file UTF-16; the `.rmskin` installer does this merge by
  itself.
- **Use `/E`, not `/MIR`.** `/MIR` deletes whatever the repository lacks, and
  the installed copy holds files it deliberately lacks -- fonts that are not
  ours to ship, such as `Cyber Track.otf` and `Track.ttf` (both gitignored),
  are only ever there. The catch with `/E` is that a file removed from the
  repository stays in the install until you delete it yourself.

Where each module sits on screen lives in Rainmeter's own `Rainmeter.ini`,
which the copy never touches.

A module that is not running yet has to be activated once:

```
"%PROGRAMFILES%\Rainmeter\Rainmeter.exe" !ActivateConfig "Kerf\Media" "Media.ini"
```

The helper writes everything it reads to `HKCU\Software\Kerf`, which is the
quickest way to tell a skin problem from a sensor problem:

```
reg query HKCU\Software\Kerf\Media
reg query HKCU\Software\Kerf\Sensors
```

Kerf draws on the desktop layer, so any open window covers it. While it is
covered, `Visible` under `HKCU\Software\Kerf\Ink` is 0 and the live measures
are paused -- show the desktop before judging how a skin looks or why the
wave has stopped moving.

## Releases

GitHub Actions does the building. Every push to `main` is checked and built on
a clean Windows machine (`.github/workflows/ci.yml`), and the resulting
`.rmskin` is kept with the run. Pushing a version tag publishes a release
(`.github/workflows/release.yml`):

Write the release notes first. The workflow publishes
`release-notes/<tag>.md` as the release body and fails if that file is
missing, so it is never possible to ship a release with no notes:

```
git add release-notes/v1.2.0.md
git commit -m "Add release notes for version 1.2.0"
git push
git tag -a v1.2.0 -m "One or two lines on what this release is about"
git push origin v1.2.0
```

A tag with a suffix (`v1.2.0-rc1`) is published as a prerelease and reads its
notes from the part before the dash.

If a release run fails and you need to tag the same version again, delete the
tag on both sides first -- moving it with `--force` leaves the old one behind
on some clones:

```
git tag -d v1.2.0
git push origin :refs/tags/v1.2.0
```

## Credits

- Chameleon plugin by Kaelri / Charles Nikkel (BSD-3), for reading the
  wallpaper.
- Bundled fonts by their respective authors under the SIL Open Font License;
  see `THIRD-PARTY-NOTICES.md`.

## Licence

MIT -- see `LICENSE`.
