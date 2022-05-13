#NoEnv 
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetKeyDelay , -1
SetMouseDelay, -1 
SetControlDelay, -1
SetWinDelay, -1

global BB_LIVE_FLAG := 0

:*:...bbreload::
	Reload
Return

:*:...bbclose::
:*:...blockerbarclose::
BlockerBarSetupGuiClose:
	Gui, BlockerBarSetup:Destroy
Return

:*:...bbopen::
:*:...blockerbaropen::
:*:...bbsetup::
:*:...blockerbarsetup::
	If ( !BB_Setup_HWND || (!WinExist("ahk_id " . BB_Setup_HWND) )) {
		Gui, BlockerBarSetup:New, +Resize HWNDbbsetuphwnd , BlockerBar - Setup
		global BB_Setup_HWND := bbsetuphwnd
		Gui, BlockerBarSetup:Color, % Format("{:s}", "000000")
		Gui, BlockerBarSetup:Font , % "c" . Format("{:s}", "FFFFFF")
		Gui, BlockerBarSetup:Add , Text, x5 y5 vBB_BoundWindow, No Bound Window
		Gui, BlockerBarSetup:Add , Button, x5 y+5 gBB_SelectWindow, Bind Window
		Gui, BlockerBarSetup:Add , Button, x+5 gBB_Confirm, Confirm

		Gui, BlockerBarSetup:Add , Text, x5 y+5, XCoord:
		Gui, BlockerBarSetup:Add , Text, x+5 w60 vBB_XCoord, -
		Gui, BlockerBarSetup:Add , Text, x+10, YCoord:
		Gui, BlockerBarSetup:Add , Text, x+5 w60 vBB_YCoord, -

		Gui, BlockerBarSetup:Add , Text, x5 y+5, XOffset:
		Gui, BlockerBarSetup:Add , Text, x+5 w60 vBB_XOffset, -
		Gui, BlockerBarSetup:Add , Text, x+10, YOffset:
		Gui, BlockerBarSetup:Add , Text, x+5 w60 vBB_YOffset, -
		Gui, BlockerBarSetup:Show, w200 h100
	} Else {
		Goto, BB_UnConfirm
	}
Return

BB_Confirm:
	BB_POS := BB_Win_GetPos("ahk_id " . BB_Setup_HWND)
	BB_LIVE_FLAG := 1
	Gui, BlockerBarSetup: -Caption -Border -SysMenu +Disabled -Resize
	Gui, BlockerBarSetup:Show, % "w" . (BB_POS["Width"]) . "h" . (BB_POS["Height"] )
	WinSet, Transparent, 255, % "ahk_id " . BB_Setup_HWND
	WinSet, ExStyle, +0x20, % "ahk_id " . BB_Setup_HWND
	WinSet, AlwaysOnTop, On, % "ahk_id " . BB_Setup_HWND
	Goto, BB_LIVE
Return

BB_UnConfirm:
	Active_Win_Array := ""
	BB_POS := BB_Win_GetPos("ahk_id " . BB_Setup_HWND)
	BB_LIVE_FLAG := 0
	Gui, BlockerBarSetup: +Caption +Border +SysMenu -Disabled +Resize
	Gui, BlockerBarSetup:Show, % "w" . ( BB_POS["Width"] -6  ) . "h" . ( BB_POS["Height"] - 29 )
	WinSet, Transparent, 255, % "ahk_id " . BB_Setup_HWND
	WinSet, ExStyle, -0x20, % "ahk_id " . BB_Setup_HWND
	WinSet, AlwaysOnTop, Off, % "ahk_id " . BB_Setup_HWND
	BB_BoundWindow_ID := "No Bound Window"
	GuiControl, , BB_BoundWindow , % BB_BoundWindow_ID
	BB_Win_Move(true)
Return

BB_SelectWindow:
	WinActivate , ahk_id %BB_Setup_HWND%
	Loop {
		If( WinActive("ahk_id " . BB_Setup_HWND) ) {
			Sleep, 10
		} Else {
			Sleep, 10
			Active_Window := WinActive()
			break
		}
	}
	Active_Win_Array := BB_Win_GetAll(Active_Window)
	BB_ActiveWindow_Msg := ""
	For key, val in Active_Win_Array { 
		BB_ActiveWindow_Msg .= key . ": " . val . "`n"
	}
	BB_Move(Active_Win_Array["x"], Active_Win_Array["y"])
	WinActivate , ahk_id %BB_Setup_HWND%
	BB_POS := BB_Win_GetPos("ahk_id " . BB_Setup_HWND)
	GuiControl, , BB_BoundWindow , % Active_Win_Array["ID"]
	GuiControl, , BB_XCoord , % Active_Win_Array["x"]
	GuiControl, , BB_YCoord , % Active_Win_Array["y"]
	GuiControl, , BB_XOffset , % BB_POS["X"] - Active_Win_Array["x"]
	GuiControl, , BB_YOffset , % BB_POS["Y"] - Active_Win_Array["y"]
	global BB_BoundWindow_ID := Active_Win_Array["ID"]
	BB_BAR_MOVE()
	OnMessage(0x0003 , "BB_BAR_MOVE")
Return

BB_LIVE:
	Loop {
		If(BB_LIVE_FLAG) {
			BB_Win_Move()
		} Else {
			break
		}
	}
Return

BB_Move(x, y) {
	WinMove, % "ahk_id " . BB_Setup_HWND, , % x , % y
}

BB_Win_Move(PWA_Reset := false){
	static Prev_Win_Array
	if(PWA_Reset == true ) {
		Prev_Win_Array := ""
		BB_TT("reset")
	}
	BB_POS := BB_Win_GetPos("ahk_id " . BB_Setup_HWND)
	if (!Prev_Win_Array){
		Prev_Win_Array := BB_Win_GetAll("ahk_id " . BB_BoundWindow_ID)
	}
	Active_Win_Array := BB_Win_GetAll("ahk_id " . BB_BoundWindow_ID)
	if ( Active_Win_Array["x"] != Prev_Win_Array["x"] ) {
		if (Active_Win_Array["x"] != Prev_Win_Array["x"] ){
			MoveBy := Active_Win_Array["x"] - Prev_Win_Array["x"]
			WinMove, % "ahk_id " . BB_Setup_HWND, , % BB_POS["X"] + MoveBy
		}
		if (Active_Win_Array["y"] != Prev_Win_Array["y"] ){
			MoveBy := Active_Win_Array["y"] - Prev_Win_Array["y"]
			WinMove, % "ahk_id " . BB_Setup_HWND, ,, % BB_POS["Y"] + MoveBy
		}
		Prev_Win_Array := Active_Win_Array
	}
}

BB_BAR_MOVE() {
	Active_Win_Array := BB_Win_GetAll("ahk_id " . BB_BoundWindow_ID)
	BB_POS := BB_Win_GetPos("ahk_id " . BB_Setup_HWND)
	GuiControl, , BB_XCoord , % Active_Win_Array["x"]
	GuiControl, , BB_YCoord , % Active_Win_Array["y"]
	GuiControl, , BB_XOffset , % BB_POS["X"] - Active_Win_Array["x"]
	GuiControl, , BB_YOffset , % BB_POS["Y"] - Active_Win_Array["y"]
}

BB_TT(msg:="", timeout:=1000){
	ToolTip 
	ToolTip % msg
	SetTimer, BB_TT-Kill, %timeout%
    return

    BB_TT-Kill:
		SetTimer, BB_TT-Kill, Off
		ToolTip
    return
}

BB_Win_GetAll(WinTitle=""){
	OutPut := {}
	If(!WinTitle)
		WinTitle := BB_Win_GetTitle()
	Output := (BB_Win_GetProperties(WinTitle ))
	Properties := BB_Win_GetPos(WinTitle)
	Output["name"] := WinTitle
	For key, val in Properties
		Output[key] := val
	Return % Output
}

BB_Win_GetProperties(WinTitle="", WinProperty="", WinText="", ExcludeTitle="", ExcludeText=""){
	WinProperties := {}
	If(!WinTitle)
		BB_Win_GetTitle()
	If(!WinProperty)
		WinProperties :=  {"ID":"",  "PID":"",  "ProcessName":"",  "ProcessPath":"",  "Count":"",  "MinMax":"",  "Transparent":"",  "TransColor":"",  "Style":"",  "ExStyle":""}
	Else
		WinProperties := WinProperty
	Prop := {}
	For Property, val in WinProperties
	{
		WinGet, val, %Property%, % WinTitle, % WinText, % ExcludeTitle, % ExcludeText
		If(val)
			Prop[Property] := val
	}
	Return Prop
}

BB_Win_GetPos(WinTitle="", WinText="", ExcludeTitle="", ExcludeText=""){
	WinPos := {}
	If(!WinTitle)
		BB_Win_GetTitle()
	WinGetPos, WinX, WinY, WinWidth, WinHeight, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	WinPos := { "X":WinX, "Y":WinY, "Width":WinWidth, "Height":WinHeight }
	For Property, val in WinPos
	{
		If(!val)
			val := % "0"
	}
	Return WinPos
}

BB_Win_GetTitle(WinTitle=""){
	If(!WinTitle){
		WinGetTitle, WinTitle, A
	} Else
		WinGetTitle, WinTitle, %WinTitle%
	Return % WinTitle
}