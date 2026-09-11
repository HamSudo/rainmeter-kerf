[Rainmeter]
Group=Kerf
AccurateText=1
OnRefreshAction=[!ZPos -2]
MouseOverAction=[!CommandMeasure mHover "Enter()"]
MouseLeaveAction=[!CommandMeasure mHover "Leave()"]
ContextTitle=Customize Kerf...
ContextAction=[!ActivateConfig "Kerf\Settings" "Settings.ini"]
ContextTitle2=Refresh all Kerf modules
ContextAction2=[!RefreshGroup Kerf]
