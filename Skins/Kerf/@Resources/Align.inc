[mDPI]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=Control Panel\Desktop\WindowMetrics
RegValue=AppliedDPI
UpdateDivider=-1

[mAlignScript]
Measure=Script
ScriptFile=#@#Scripts\Align.lua

[mAlign]
Measure=Calc
Formula=(#AlignMode# > 0) ? #AlignMode# : (((#CURRENTCONFIGX# + #CURRENTCONFIGWIDTH# / 2 - #WORKAREAX#) < (#WORKAREAWIDTH# / 3)) ? 1 : (((#CURRENTCONFIGX# + #CURRENTCONFIGWIDTH# / 2 - #WORKAREAX#) > (#WORKAREAWIDTH# * 2 / 3)) ? 3 : 2))
DynamicVariables=1
IfCondition=mAlign = 1
IfTrueAction=[!SetVariable AF 0][!UpdateMeter *][!Redraw]
IfCondition2=mAlign = 2
IfTrueAction2=[!SetVariable AF 0.5][!UpdateMeter *][!Redraw]
IfCondition3=mAlign = 3
IfTrueAction3=[!SetVariable AF 1][!UpdateMeter *][!Redraw]
IfCondition4=mAlign >= 4
IfTrueAction4=[!SetVariable AF 0.5][!UpdateMeter *][!Redraw]
