[mTemp]
Measure=Registry
RegHKey=HKEY_CURRENT_USER
RegKey=SOFTWARE\HWiNFO64\VSB
RegValue=ValueRaw#Idx#

[mTempText]
Measure=Calc
Formula=Round(mTemp)
RegExpSubstitute=1
Substitute="^0$":"--"

[mTempPct]
Measure=Calc
Formula=Clamp((mTemp - #TempMin#) / (#TempMax# - #TempMin#), 0, 1)

[MeterBox]
MeterStyle=sHitBox
W=(120*#Scale#)
H=([MeterRuler:YH] + 2*#Scale#)

[MeterVal]
Meter=String
MeterStyle=sBase
MeasureName=mTempText
Text=%1°C
FontSize=(15*#Scale#)
FontWeight=#DayWeight#
FontColor=#Ink#,#A2#
InlineSetting2=Size | (8*#Scale#)
InlinePattern2=°C
InlineSetting3=Color | #Ink#,110
InlinePattern3=°C
X=((#AF# = 1) ? (120*#Scale# - [MeterLbl:W] - 10*#Scale# - [MeterVal:W]) : ([MeterLbl:X] + [MeterLbl:W] + 10*#Scale#))
Y=0

[MeterLbl]
Meter=String
MeterStyle=sBase | sMono
Text=#Label#
FontSize=(7.5*#Scale#)
X=((#AF# = 1) ? (120*#Scale# - [MeterLbl:W]) : (#AF# * (120*#Scale# - [MeterLbl:W] - 10*#Scale# - [MeterVal:W])))
Y=([MeterVal:Y] + [MeterVal:H] - [MeterLbl:H] - 3*#Scale#)

[MeterRuler]
Meter=Shape
DynamicVariables=1
X=(#AF# * (120*#Scale# - 64*#Scale#))
Y=([MeterVal:YH] + 3*#Scale#)
Shape=Rectangle 0,(4*#Scale#),(64*#Scale#),(1*#Scale#) | Fill Color #Ink#,56 | StrokeWidth 0
Shape2=Rectangle (0*#Scale#),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,97 | StrokeWidth 0
Shape3=Rectangle (8*#Scale#),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,97 | StrokeWidth 0
Shape4=Rectangle (16*#Scale#),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,97 | StrokeWidth 0
Shape5=Rectangle (24*#Scale#),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,97 | StrokeWidth 0
Shape6=Rectangle (32*#Scale#),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,97 | StrokeWidth 0
Shape7=Rectangle (40*#Scale#),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,97 | StrokeWidth 0
Shape8=Rectangle (48*#Scale#),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,97 | StrokeWidth 0
Shape9=Rectangle (56*#Scale#),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,97 | StrokeWidth 0
Shape10=Rectangle (63*#Scale#),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,97 | StrokeWidth 0
Shape11=Rectangle ([mTempPct:]*62*#Scale#),0,(2*#Scale#),(5*#Scale#) | Fill Color #AccInk#,255 | StrokeWidth 0
