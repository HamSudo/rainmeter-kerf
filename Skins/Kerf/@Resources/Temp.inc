[MeterBox]
Meter=Image
MeterStyle=sHitBox
W=#RowW#
H=((#Flip# = 1) ? ([MeterVal:Y] + [MeterVal:H] + #Scale#) : ([MeterRuler:Y] + 6*#Scale#))

[MeterLblRef]
Meter=String
MeterStyle=sBase | sMono
Text=iGPU
FontSize=(7.5*#Scale#)
FontColor=0,0,0,0
InlineSetting=Shadow | 0 | 0 | 0 | 0,0,0,0
X=0
Y=0

[MeterValRef]
Meter=String
MeterStyle=sBase
Text=88°C
FontSize=(15*#Scale#)
FontWeight=#DayWeight#
FontColor=0,0,0,0
InlineSetting=Shadow | 0 | 0 | 0 | 0,0,0,0
InlineSetting2=Size | (8*#Scale#)
InlinePattern2=°C
X=0
Y=0

[MeterVal]
Meter=String
MeterStyle=sBase
MeasureName=mTempText
InlineSetting4=CharacterSpacing | 0 | #TempTracking# | 0
Text=%1°C
FontSize=(15*#Scale#)
FontWeight=#DayWeight#
FontColor=#Ink#,(#A2#*#FadeK#)
InlineSetting2=Size | (8*#Scale#)
InlinePattern2=°C
InlineSetting3=Color | #Ink#,(130*#FadeK#)
InlinePattern3=°C
X=((#AF# = 1) ? ([MeterValRef:W] - [MeterVal:W]) : (#RowW# - [MeterVal:W]))
Y=(#Flip# * 8*#Scale#)

[MeterLbl]
Meter=String
MeterStyle=sBase | sMono
Text=#Label#
FontSize=(7.5*#Scale#)
X=((#AF# = 1) ? (#RowW# - [MeterLbl:W]) : 0)
Y=([MeterVal:Y] + [MeterVal:H] - [MeterLbl:H] - 3*#Scale#)

[MeterRuler]
Meter=Shape
DynamicVariables=1
X=0
Y=((#Flip# = 1) ? 0 : ([MeterVal:Y] + [MeterVal:H] + 3*#Scale#))
Shape=Rectangle 0,(4*#Scale#*(1 - #Flip#)),(#RowW#),(1*#Scale#) | Fill Color #Ink#,(56*#FadeK#) | StrokeWidth 0
Shape2=Rectangle (0*(#RowW# - #Scale#)/8),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape3=Rectangle (1*(#RowW# - #Scale#)/8),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape4=Rectangle (2*(#RowW# - #Scale#)/8),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape5=Rectangle (3*(#RowW# - #Scale#)/8),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape6=Rectangle (4*(#RowW# - #Scale#)/8),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape7=Rectangle (5*(#RowW# - #Scale#)/8),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape8=Rectangle (6*(#RowW# - #Scale#)/8),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape9=Rectangle (7*(#RowW# - #Scale#)/8),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape10=Rectangle (8*(#RowW# - #Scale#)/8),(1*#Scale#),(1*#Scale#),(3*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape11=Rectangle ([mTempPct:]*(#RowW# - 2*#Scale#)),0,(2*#Scale#),(5*#Scale#) | Fill Color #AccInk#,(255*#FadeK#) | StrokeWidth 0
