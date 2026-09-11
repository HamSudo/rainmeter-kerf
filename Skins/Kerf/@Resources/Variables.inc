; Kerf settings. Most are set from Customize Kerf; refresh Kerf after editing.
[Variables]

; Fonts
FontFace=Hanken Grotesk
MonoFace=JetBrains Mono
TimeSize=100
TimeWeight=300
DayFace=#FontFace#
DayItalic=0
DayScale=0.19
DayWeight=400
TimeTracking=-2
MicroTracking=2

; Set by the font picker
VDigitGap=0
TempTracking=0
VCapTop=0.226
VBase=0.767
VDotW=0.058
VDotH=0.083
VDotGap=0.196
VDotR=0

; Display: 0 auto, 1 1080p, 2 1440p, 3 4K
DisplayMode=0
BaseScale=((#DisplayMode# = 1) ? 1 : ((#DisplayMode# = 2) ? 1.3333 : ((#DisplayMode# = 3) ? 2 : 1)))

; Alignment margin (px)
EdgeMargin=48

; Clock
TimeFormat=%H:%M
HourFormat=%H

; Music line: glow, pulse or wave
WaveStyle=glow
WavePulseSpeed=0.6
WaveLine=110
WaveHeight=30
WaveAmp=0.9
WaveStroke=1.5
WaveFrequency=12
WaveSpeed=0.05
WaveSpread=1.2
WaveGain=2
WaveFollowVolume=1
WaveEcho1=0
WaveEcho2=0

; Accent
Accent=242,184,75
AccentOnLight=150,114,46

; Ink: 0 auto, 1 light, 2 dark
InkMode=0
InkThreshold=0.18
InkDivider=1
WEConfig=
InkLight=244,246,248
InkDark=17,22,27
HaloLight=0,0,0
HaloDark=255,255,255

; Opacity (0-255)
A1=255
A2=200
A3=150
A4=90

; Temperature range (C)
TempMin=30
TempMax=100


; Set automatically
InkSource=none
Ink=244,246,248
Halo=0,0,0
AccInk=242,184,75
AF=0
FadeK=1
