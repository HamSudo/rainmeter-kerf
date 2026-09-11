[mHover]
Measure=Script
ScriptFile=#@#Scripts\Hover.lua

[mFader]
Measure=Plugin
Plugin=ActionTimer
ActionList1=Repeat Step, 16, 14
Step=[!CommandMeasure mHover "Step()"]
IgnoreWarnings=1
