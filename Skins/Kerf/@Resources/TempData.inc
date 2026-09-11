[mLaunch]
Measure=Plugin
Plugin=RunCommand
Program="#@#Bin\KerfSensors.exe"
State=Hide
Timeout=-1

[mBuild]
Measure=Plugin
Plugin=RunCommand
Program="%WINDIR%\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
Parameter=/nologo /target:winexe /optimize /out:"#@#Bin\KerfSensors.exe" "#@#Bin\KerfSensors.cs"
State=Hide
FinishAction=[!CommandMeasure mLaunch "Run"]

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
