[mWE64]
Measure=Plugin
Plugin=UsageMonitor
Alias=RAM
Name=wallpaper64
UpdateDivider=#InkDivider#

[mWE32]
Measure=Plugin
Plugin=UsageMonitor
Alias=RAM
Name=wallpaper32
UpdateDivider=#InkDivider#

[mSteamPath]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Valve\Steam
RegValue=SteamPath
UpdateDivider=-1

[mBgType]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers
RegValue=BackgroundType
UpdateDivider=#InkDivider#

[mBgColor]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Control Panel\Colors
RegValue=Background
UpdateDivider=#InkDivider#

[mWinWall]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Control Panel\Desktop
RegValue=WallPaper
UpdateDivider=#InkDivider#

[mChameleon]
Measure=Plugin
Plugin=Chameleon
Type=Desktop
Format=Dec
UpdateDivider=#InkDivider#

[mAvgColor]
Measure=Plugin
Plugin=Chameleon
Parent=mChameleon
Color=Average
UpdateDivider=#InkDivider#

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
Parameter=/nologo /target:winexe /optimize /r:System.Drawing.dll /out:"#@#Bin\KerfSensors.exe" "#@#Bin\KerfSensors.cs"
State=Hide
FinishAction=[!CommandMeasure mLaunch "Run"]

[mScreenLum]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Ink
RegValue=Clock
UpdateDivider=#InkDivider#

[mScreenTick]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Ink
RegValue=Tick
UpdateDivider=#InkDivider#

[mScreenAlive]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Ink
RegValue=Alive
UpdateDivider=#InkDivider#

[mVisible]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Software\Kerf\Ink
RegValue=Visible
UpdateDivider=#InkDivider#
IfMatch=^0$
IfMatchAction=[!PauseMeasureGroup Live]
IfNotMatchAction=[!UnpauseMeasureGroup Live]

[mInkScript]
Measure=Script
ScriptFile=#@#Scripts\Ink.lua
UpdateDivider=#InkDivider#
DynamicVariables=1
IfCondition=(#InkMode# = 2) || ((#InkMode# = 0) && (mInkScript > #InkThreshold#))
IfTrueAction=[!SetVariable Ink "#InkDark#"][!SetVariable Halo "#HaloDark#"][!SetVariable AccInk "#AccentOnLight#"][!UpdateMeter *][!Redraw]
IfFalseAction=[!SetVariable Ink "#InkLight#"][!SetVariable Halo "#HaloLight#"][!SetVariable AccInk "#Accent#"][!UpdateMeter *][!Redraw]
