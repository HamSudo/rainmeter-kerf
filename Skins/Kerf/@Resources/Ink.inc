[mChameleon]
Measure=Plugin
Plugin=Chameleon
Type=Desktop

[mLuminance]
Measure=Plugin
Plugin=Chameleon
Parent=mChameleon
Color=Luminance
DynamicVariables=1
IfCondition=(#InkMode# = 2) || ((#InkMode# = 0) && (mLuminance > #InkThreshold#))
IfTrueAction=[!SetVariable Ink "#InkDark#"][!SetVariable Halo "#HaloDark#"][!SetVariable AccInk "#AccentOnLight#"][!UpdateMeter *][!Redraw]
IfFalseAction=[!SetVariable Ink "#InkLight#"][!SetVariable Halo "#HaloLight#"][!SetVariable AccInk "#Accent#"][!UpdateMeter *][!Redraw]
