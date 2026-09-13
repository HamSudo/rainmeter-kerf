; What the Windows media session is playing, as KerfSensors writes it to
; HKCU\Software\Kerf\Media. Media.lua turns it into text, a progress
; fraction and the angle of the disc.
[mMediaTick]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Media
RegValue=Tick

[mTitle]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Media
RegValue=Title

[mArtist]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Media
RegValue=Artist

[mStatus]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Media
RegValue=Status

[mPos]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Media
RegValue=Pos

[mLen]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Media
RegValue=Len

[mPosAt]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Media
RegValue=PosAt

[mArt]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Media
RegValue=Art

[mDisc]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Media
RegValue=Disc

[mMedia]
Measure=Script
Group=Live
ScriptFile=#@#Scripts\Media.lua
