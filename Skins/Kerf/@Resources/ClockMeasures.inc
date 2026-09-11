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

[mTag]
Measure=Time
Format=#TagFormat#
UpdateDivider=30

[mDay]
Measure=Time
Format=%A
UpdateDivider=30

[mDMY]
Measure=Time
Format=%d / %m / %Y
UpdateDivider=30

[mDMYShort]
Measure=Time
Format=%d/%m/%y
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

[mAudio]
Measure=Plugin
Plugin=AudioLevel
Port=Output
RMSAttack=40
RMSDecay=300
RMSGain=#WaveGain#
Sensitivity=35

[mLevel]
Measure=Plugin
Plugin=AudioLevel
Parent=mAudio
Type=RMS
Channel=Avg

[mVolume]
Measure=Plugin
Plugin=Win7AudioPlugin
UpdateDivider=15
