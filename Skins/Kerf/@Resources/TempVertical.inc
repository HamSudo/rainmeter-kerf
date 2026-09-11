[mLabelStack]
Measure=Script
ScriptFile=#@#Scripts\Stack.lua
Mode=letters
SourceVar=Label
Prefix=MeterL
Count=4
Slots=4
MaxSize=(7.5*#Scale#)
LengthFormula=(46*#Scale#)
TopFormula=(1*#Scale#)

[MeterBox]
Meter=Image
MeterStyle=sHitBox
W=(#ColX# + [MeterValRef:W])
H=([MeterUnit:Y] + [MeterUnit:H])

[MeterValRef]
Meter=String
MeterStyle=sBase
Text=88
FontSize=(15*#Scale#)
FontWeight=#TempWeight#
FontColor=0,0,0,0
InlineSetting=Shadow | 0 | 0 | 0 | 0,0,0,0
X=0
Y=0

[sLetter]
StringAlign=Center
X=(#ColX# + [MeterValRef:W]/2)
Hidden=1

[MeterL1]
Meter=String
MeterStyle=sBase | sMono | sLetter
[MeterL2]
Meter=String
MeterStyle=sBase | sMono | sLetter
[MeterL3]
Meter=String
MeterStyle=sBase | sMono | sLetter
[MeterL4]
Meter=String
MeterStyle=sBase | sMono | sLetter

[MeterVal]
Meter=String
MeterStyle=sBase
MeasureName=mTempText
InlineSetting2=CharacterSpacing | 0 | #TempTracking# | 0
Text=%1
FontSize=(15*#Scale#)
FontWeight=#TempWeight#
FontColor=#Ink#,(#A2#*#FadeK#)
StringAlign=Center
X=(#ColX# + [MeterValRef:W]/2)
Y=(50*#Scale#)

[MeterUnit]
Meter=String
MeterStyle=sBase | sMono
Text=°C
FontSize=(7.5*#Scale#)
StringAlign=Center
X=(#ColX# + [MeterValRef:W]/2)
Y=([MeterVal:Y] + [MeterVal:H] - 2*#Scale#)

[MeterRuler]
Meter=Shape
DynamicVariables=1
X=(#Flip# * ([MeterValRef:W] + 5*#Scale#))
Y=0
Shape=Rectangle (4*#Scale#*#Flip#),0,(1*#Scale#),(#RH#) | Fill Color #Ink#,(56*#FadeK#) | StrokeWidth 0
Shape2=Rectangle (1*#Scale#),(0*(#RH# - #Scale#)/8),(3*#Scale#),(1*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape3=Rectangle (1*#Scale#),(1*(#RH# - #Scale#)/8),(3*#Scale#),(1*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape4=Rectangle (1*#Scale#),(2*(#RH# - #Scale#)/8),(3*#Scale#),(1*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape5=Rectangle (1*#Scale#),(3*(#RH# - #Scale#)/8),(3*#Scale#),(1*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape6=Rectangle (1*#Scale#),(4*(#RH# - #Scale#)/8),(3*#Scale#),(1*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape7=Rectangle (1*#Scale#),(5*(#RH# - #Scale#)/8),(3*#Scale#),(1*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape8=Rectangle (1*#Scale#),(6*(#RH# - #Scale#)/8),(3*#Scale#),(1*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape9=Rectangle (1*#Scale#),(7*(#RH# - #Scale#)/8),(3*#Scale#),(1*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape10=Rectangle (1*#Scale#),(8*(#RH# - #Scale#)/8),(3*#Scale#),(1*#Scale#) | Fill Color #Ink#,(97*#FadeK#) | StrokeWidth 0
Shape11=Rectangle 0,((1 - [mTempPct:])*(#RH# - 2*#Scale#)),(5*#Scale#),(2*#Scale#) | Fill Color #AccInk#,(255*#FadeK#) | StrokeWidth 0
