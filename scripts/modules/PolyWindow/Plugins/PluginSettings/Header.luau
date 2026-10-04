local set = {
	maximizeOnDoubleTapTime = 0.25, --maximize window if the header is double-tapped (set to <= 0 to disable)
	minimizeOnFloor = true, --minimize window if the mouse's position is at the floor of the container
	snapWindows = true, --snap windows to snapData
	snapTolerance = 25, --px,
	overrideExitFont = true,
	snapData = { --detection point x,y -> scale x,y
		{0,0,	0.5,0.5}, --top-left
		{1,0,	0.5,0.5}, --top-right
		{0,1,	0.5,0.5}, --bottom-left
		{1,1,	0.5,0.5}, --bottom-right
		{0,0.5,	0.5,1}, --left
		{1,0.5,	0.5,1}, --right
		{0.5,0,	1,1}, --maximize
	}
}

return set