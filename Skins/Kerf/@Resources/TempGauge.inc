[mGauge]
Measure=Script
ScriptFile=#@#Scripts\Gauge.lua

[mInkL]
Measure=Calc
Formula=(#GC# - #GR# - #GS#/2)

[mInkT]
Measure=Calc
Formula=(#GC# - #GR# - #GS#/2)

[mInkR]
Measure=Calc
Formula=(#GC# + #GR# + #GS#/2)

[mInkB]
Measure=Calc
Formula=Max(#GC# + #GR#*0.7071 + #GS#/2, #GC# + #GR#*0.9 + 3*#Scale#)

[MeterBox]
Meter=Image
MeterStyle=sHitBox
W=#GD#
H=#GD#

[MeterRing]
Meter=Shape
DynamicVariables=1
X=0
Y=0
Shape=Arc (#GC# + #GR#*Cos(0.75*PI)),(#GC# + #GR#*Sin(0.75*PI)),(#GC# + #GR#*Cos(2.25*PI)),(#GC# + #GR#*Sin(2.25*PI)),#GR#,#GR#,0,0,1 | StrokeWidth #GS# | Stroke Color #Ink#,(38*#FadeK#) | Fill Color 0,0,0,0 | StrokeStartCap Round | StrokeEndCap Round
Shape2=Arc (#GC# + #GR#*Cos(0.75*PI)),(#GC# + #GR#*Sin(0.75*PI)),(#GC# + #GR#*Cos((0.75 + 1.5*Max([mTempPct:], 0.004))*PI)),(#GC# + #GR#*Sin((0.75 + 1.5*Max([mTempPct:], 0.004))*PI)),#GR#,#GR#,0,0,(([mTempPct:] > 0.6667) ? 1 : 0) | StrokeWidth #GS# | Stroke Color #Heat#,((([mTemp:] > 0) ? 255 : 0)*#FadeK#) | Fill Color 0,0,0,0 | StrokeStartCap Round | StrokeEndCap Round

[MeterVal]
Meter=String
MeterStyle=sBase
MeasureName=mTempText
Text=%1 °C
InlineSetting2=CharacterSpacing | 0 | #TempTracking# | 0
InlineSetting3=Size | (6.5*#Scale#)
InlinePattern3=\x20°C
InlineSetting4=Color | #Ink#,(130*#FadeK#)
InlinePattern4=°C
FontSize=(14*#Scale#)
FontWeight=#TempWeight#
FontColor=#Ink#,(#A2#*#FadeK#)
StringAlign=CenterCenter
X=(#GC# + 2*#Scale#)
Y=(#GC# - 1*#Scale#)

[MeterLbl]
Meter=String
MeterStyle=sBase | sMono
Text=#Label#
FontSize=(6.5*#Scale#)
FontColor=#Ink#,(150*#FadeK#)
StringAlign=CenterCenter
X=#GC#
Y=(#GC# + #GR#*0.9)
