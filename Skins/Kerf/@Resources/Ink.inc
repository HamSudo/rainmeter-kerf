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

[mInkScript]
Measure=Script
ScriptFile=#@#Scripts\Ink.lua
UpdateDivider=#InkDivider#
DynamicVariables=1
IfCondition=(#InkMode# = 2) || ((#InkMode# = 0) && (mInkScript > #InkThreshold#))
IfTrueAction=[!SetVariable Ink "#InkDark#"][!SetVariable Halo "#HaloDark#"][!SetVariable AccInk "#AccentOnLight#"][!UpdateMeter *][!Redraw]
IfFalseAction=[!SetVariable Ink "#InkLight#"][!SetVariable Halo "#HaloLight#"][!SetVariable AccInk "#Accent#"][!UpdateMeter *][!Redraw]
