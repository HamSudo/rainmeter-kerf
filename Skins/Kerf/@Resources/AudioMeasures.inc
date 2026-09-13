; What is playing, for the music line. Shared by the clock and the
; media card.
[mAudio]
Measure=Plugin
Group=Live
Plugin=AudioLevel
Port=Output
RMSAttack=40
RMSDecay=300
RMSGain=#WaveGain#
FFTSize=1024
FFTOverlap=512
FFTAttack=10
FFTDecay=120
Bands=8
FreqMin=30
FreqMax=16000
Sensitivity=35

[mLevel]
Measure=Plugin
Group=Live
Plugin=AudioLevel
Parent=mAudio
Type=RMS
Channel=Avg

[mVolume]
Measure=Plugin
Group=Live
Plugin=Win7AudioPlugin
UpdateDivider=15

[mBass0]
Measure=Plugin
Group=Live
Plugin=AudioLevel
Parent=mAudio
Type=Band
BandIdx=0

[mBass1]
Measure=Plugin
Group=Live
Plugin=AudioLevel
Parent=mAudio
Type=Band
BandIdx=1
