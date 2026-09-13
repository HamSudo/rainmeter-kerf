[mTime]
Measure=Time
Format=#TimeFormat#
UpdateDivider=30

[mHour]
Measure=Time
Format=#HourFormat#
UpdateDivider=30

[mMinute]
Measure=Time
Format=%M
UpdateDivider=30

[mSec]
Measure=Time
Format=%S
UpdateDivider=15

[mDay]
Measure=Time
Format=%a
UpdateDivider=30

[mDayFull]
Measure=Time
Format=%A
UpdateDivider=30

[mDMY]
Measure=Time
Format=%d %b
UpdateDivider=30

[mDMYShort]
Measure=Time
Format=%d %b
UpdateDivider=30

[mMonth]
Measure=Time
Format=%b
UpdateDivider=30

[mDayStyle]
Measure=String
String=#DayItalic#
RegExpSubstitute=1
Substitute="^1$":"Italic","^0$":"Normal"
UpdateDivider=-1

[mDaySize]
Measure=Calc
Formula=(#TimeSize#*#DayScale#*#Scale#)
UpdateDivider=-1

[mFirstRun]
Measure=Calc
Formula=#FirstRun#
IfCondition=mFirstRun = 1
IfTrueAction=[!WriteKeyValue Variables FirstRun 0 "#@#Modules.inc"][!SetVariable FirstRun 0][!ActivateConfig "Kerf\CPU" "CPU.ini"][!ActivateConfig "Kerf\GPU" "GPU.ini"][!ActivateConfig "Kerf\Media" "Media.ini"][!ActivateConfig "Kerf\Settings" "Settings.ini"]
