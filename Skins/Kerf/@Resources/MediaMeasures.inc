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

; deliberately not in the Live group: a hidden card is not on screen for the
; helper to see, and were it the only module up the group would pause -- with
; nothing left running to notice that something started playing again
[mMedia]
Measure=Script
ScriptFile=#@#Scripts\Media.lua
