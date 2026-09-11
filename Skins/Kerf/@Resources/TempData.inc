[mTick]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Ink
RegValue=Alive

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
Both=#Pair#

[mTempText]
Measure=Calc
Formula=((mTemp = 0) ? 0 : Round((#Fahr# = 1) ? (mTemp*1.8 + 32) : mTemp))
RegExpSubstitute=1
Substitute="^0$":"--"

[mTempPct]
Measure=Calc
Formula=Clamp((mTemp - #TempMin#) / (#TempMax# - #TempMin#), 0, 1)

[mRaw2]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Sensors
RegValue=iGPU

[mTemp2]
Measure=Script
ScriptFile=#@#Scripts\Temp.lua
Kind=GPU
Raw=mRaw2
LabelVar=Label2
Both=#Pair#
Slot=2

[mTempText2]
Measure=Calc
Formula=((mTemp2 = 0) ? 0 : Round((#Fahr# = 1) ? (mTemp2*1.8 + 32) : mTemp2))
RegExpSubstitute=1
Substitute="^0$":"--"

[mTempPct2]
Measure=Calc
Formula=Clamp((mTemp2 - #TempMin#) / (#TempMax# - #TempMin#), 0, 1)
