[Rainmeter]
Group=Kerf
AccurateText=1
OnRefreshAction=[!ZPos -2]
MouseOverAction=[!CommandMeasure mHover "Enter()"]
MouseLeaveAction=[!CommandMeasure mHover "Leave()"]
ContextTitle=Align: follow position (auto)
ContextAction=[!CommandMeasure mAlignScript "Snap(0)"]
ContextTitle2=Align: left edge
ContextAction2=[!CommandMeasure mAlignScript "Snap(1)"]
ContextTitle3=Align: centre of screen
ContextAction3=[!CommandMeasure mAlignScript "Snap(2)"]
ContextTitle4=Align: right edge
ContextAction4=[!CommandMeasure mAlignScript "Snap(3)"]
ContextTitle5=Customize Kerf...
ContextAction5=[!ActivateConfig "Kerf\Settings" "Settings.ini"]
ContextTitle6=Refresh all Kerf modules
ContextAction6=[!RefreshGroup Kerf]
