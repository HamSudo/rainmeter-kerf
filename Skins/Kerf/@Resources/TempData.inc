[mTick]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Sensors
RegValue=Tick

[mRaw]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Sensors
RegValue=#Kind#

[mGpuKind]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Sensors
RegValue=GPUKind

[mTemp]
Measure=Script
ScriptFile=#@#Scripts\Temp.lua
Kind=#Kind#

[mTempText]
Measure=Calc
Formula=Round(mTemp)
RegExpSubstitute=1
Substitute="^0$":"--"

[mTempPct]
Measure=Calc
Formula=Clamp((mTemp - #TempMin#) / (#TempMax# - #TempMin#), 0, 1)
