[mRowH]
Measure=Calc
Formula=(((#Flip# = 1) ? ([MeterVal:Y] + [MeterVal:H] + #Scale#) : ([MeterRuler:Y] + 6*#Scale#)) + 10*#Scale#)
DynamicVariables=1

[mInkL]
Measure=Calc
Formula=0

[mInkR]
Measure=Calc
Formula=#RowW#
DynamicVariables=1

[mInkT]
Measure=Calc
Formula=((#Flip# = 1) ? 0 : ([MeterVal:Y] + [MeterVal:H]*#VCapTop#))
DynamicVariables=1

[mInkB]
Measure=Calc
Formula=(#Pair#*[mRowH:] + ((#Flip# = 1) ? ([MeterVal:Y] + [MeterVal:H]*#VBase#) : ([MeterRuler:Y] + 5*#Scale#)))
DynamicVariables=1

[MeterBox]
Meter=Image
MeterStyle=sHitBox
W=#RowW#
H=(#Pair#*[mRowH:] + ((#Flip# = 1) ? ([MeterVal:Y] + [MeterVal:H] + #Scale#) : ([MeterRuler:Y] + 6*#Scale#)))

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
Text=[#Ref[#Fahr]][#Sym[#Fahr]]
FontSize=(15*#Scale#)
FontWeight=#TempWeight#
FontColor=0,0,0,0
InlineSetting=Shadow | 0 | 0 | 0 | 0,0,0,0
InlineSetting2=Size | (8*#Scale#)
InlinePattern2=°[CF]
X=0
Y=0

[MeterVal]
Meter=String
MeterStyle=sBase
MeasureName=mTempText
InlineSetting4=CharacterSpacing | 0 | #TempTracking# | 0
Text=%1[#Sym[#Fahr]]
FontSize=(15*#Scale#)
FontWeight=#TempWeight#
FontColor=#Ink#,(#A2#*#FadeK#)
InlineSetting2=Size | (8*#Scale#)
InlinePattern2=°[CF]
InlineSetting3=Color | #Ink#,(130*#FadeK#)
InlinePattern3=°[CF]
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

[MeterVal2]
Meter=String
MeterStyle=sBase
Hidden=(1 - #Pair#)
MeasureName=mTempText2
InlineSetting4=CharacterSpacing | 0 | #TempTracking# | 0
Text=%1[#Sym[#Fahr]]
FontSize=(15*#Scale#)
FontWeight=#TempWeight#
FontColor=#Ink#,(#A2#*#FadeK#)
InlineSetting2=Size | (8*#Scale#)
InlinePattern2=°[CF]
InlineSetting3=Color | #Ink#,(130*#FadeK#)
InlinePattern3=°[CF]
X=((#AF# = 1) ? ([MeterValRef:W] - [MeterVal2:W]) : (#RowW# - [MeterVal2:W]))
Y=([mRowH:] + #Flip# * 8*#Scale#)

[MeterLbl2]
Meter=String
MeterStyle=sBase | sMono
Hidden=(1 - #Pair#)
Text=#Label2#
FontSize=(7.5*#Scale#)
X=((#AF# = 1) ? (#RowW# - [MeterLbl2:W]) : 0)
Y=([MeterVal2:Y] + [MeterVal2:H] - [MeterLbl2:H] - 3*#Scale#)

[MeterRuler2]
Meter=Shape
DynamicVariables=1
Hidden=(1 - #Pair#)
X=0
Y=((#Flip# = 1) ? [mRowH:] : ([MeterVal2:Y] + [MeterVal2:H] + 3*#Scale#))
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
Shape11=Rectangle ([mTempPct2:]*(#RowW# - 2*#Scale#)),0,(2*#Scale#),(5*#Scale#) | Fill Color #AccInk#,(255*#FadeK#) | StrokeWidth 0
