;;;;;;;;;; Loading ;;;;;;;;;;
    #SingleInstance, Force
    #Persistent
    #NoEnv
    ;#NoTrayIcon
    ;--------------------------------------------------
    #KeyHistory, 0
    ;#InstallKeybdHook
    ;#InstallMouseHook
    ;#UseHook
    ;--------------------------------------------------
    #MaxHotkeysPerInterval, 9999999
    #HotkeyInterval, 9999999
    ;--------------------------------------------------
    #MaxThreads, 255
    ;#MaxThreadsPerHotkey, 255
    ;--------------------------------------------------
    Process, Priority,, A
    CoordMode, ToolTip, Screen
    CoordMode, Pixel, Screen
    ListLines Off
    SendMode, Event ; Input
    SetBatchLines -1
    SetKeyDelay, -1, -1
    SetMouseDelay, -1, -1
    SetControlDelay -1
    SetWinDelay -1

;;;;;;;;;; Run as Administrator ;;;;;;;;;;
    ; https://www.autohotkey.com/docs/v1/lib/Run.htm#RunAs
    full_command_line := DllCall("GetCommandLine", "str")
    if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)")) {
        try { ; leads to having the script re-launching itself as administrator
            if A_IsCompiled
                Run *RunAs "%A_ScriptFullPath%" /restart
            else
                Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }
        ExitApp
    }
    full_command_line := ""

;;;;;;;;;; Include ;;;;;;;;;;
    #include %A_Scriptdir%\..\
    SetWorkingDir %A_ScriptDir%\..\
    
    #include %A_Scriptdir%\..\BaseLibs\WorkingWithFiles.ahk
    #include %A_Scriptdir%\..\BaseLibs\TimeControl.ahk
    #include %A_Scriptdir%\..\BaseLibs\MiscFunction.ahk
    #include %A_Scriptdir%\..\AuxiliaryScripts\Gdip.ahk

;;;;;;;;;; Variables ;;;;;;;;;;
    global gScreen       := [Round(A_ScreenWidth), Round(A_ScreenHeight)]
    global gScreenCenter := [Round(A_ScreenWidth / 2), Round(A_ScreenHeight / 2)] 
    global gFontScaling  := Round(A_ScreenHeight / 1080, 2)
    global gDPI          := (96 / A_ScreenDPI) 
    ;--------------------------------------------------
    CheckingFiles("File", True, "Base_ICO")
    ;--------------------------------------------------
    CB_AlwaysOnTop := True
    ActualWidth    := A_ScreenWidth
    ActualHeight   := A_ScreenHeight

;;;;;;;;;; Tray Menu ;;;;;;;;;;
    Menu, Tray, Tip, Coordinate Converter
    Menu, Tray, icon, %OP_Base_ICO%,31, 1

    Menu, Tray, NoStandard
    funcObj := Func("Tray_links").Bind("Discord")
    Menu, Tray, Add, Discord, %funcObj%
    Menu, Tray, icon, Discord, %OP_Base_ICO%,16

    funcObj := Func("Tray_links").Bind("GitHub")
    Menu, Tray, Add, GitHub, %funcObj%
    Menu, Tray, icon, GitHub, %OP_Base_ICO%,17

    funcObj := Func("Tray_links").Bind("Donate")
    Menu, Tray, Add, Donate, %funcObj%
    Menu, Tray, icon, Donate, %OP_Base_ICO%,28

    Menu, Tray, Add
    funcObj := Func("Tray_links").Bind("Reload")
    Menu, Tray, Add, Reload, %funcObj% 
    Menu, Tray, icon, Reload, %OP_Base_ICO%,5

    funcObj := Func("Tray_links").Bind("Stop")
    Menu, Tray, Add, Stop (exit), %funcObj% 
    Menu, Tray, icon, Stop (exit), %OP_Base_ICO%,3

    Menu, Tray, Default, Stop (exit)
    ;--------------------------------------------------
    Tray_links(param) {
        switch param {
            case "Discord" : Run, https://discord.gg/yrRfUMXAnk
            case "GitHub"  : Run, https://github.com/YagamiKlait3579
            case "Donate"  : Run, https://www.tbank.ru/rm/r_ZjWxmKELuP.YfEdKjOhWm/tJx2U7674/
            ;--------------------------------------------------
            case "Reload"  : Reload
            case "Stop"    : ExitApp
        }
    }

;;;;;;;;;; Gui ;;;;;;;;;;
    FontSize := Round((12 * gFontScaling) * gDPI)
    ColorText  := "ff7d19"
    ColorText2 := "Fuchsia"
    ColorText3 := "Aqua"
    ColorText4 := "Yellow"
    ColorBG    := "1e1e1e"
    Gui, CoordinateConverter: +AlwaysOnTop +LastFound -DPIScale +Border -MinimizeBox +HwndCoordinateConverter
    Gui, CoordinateConverter: Color, %ColorBG%
    Gui, CoordinateConverter: Font, % " s"FontSize " q3", MS Sans Serif
    Gui, CoordinateConverter: Show, % " w"(A_ScreenWidth/3) " h"(A_ScreenWidth/3/16*9), Coordinate Converter
    WinGetPos, CC_X, CC_Y, CC_W, CC_H, ahk_id %CoordinateConverter%
    ;--------------------------------------------------
    Gui, CoordinateConverter: Add, Picture, % " x" CC_W*0.1 " y"CC_H*0.75 " w"CC_W*0.15 " h-1 +Border +BackgroundTrans vDiscordGUI", % "HBITMAP:" ReadImages(CheckingFiles("File", False, "Base_Images.dll"), "Discord1")
    funcObj := Func("Tray_links").Bind("Discord")
    GuiControl CoordinateConverter: +g, DiscordGUI, %funcObj%
    ;--------------------------------------------------
    Gui, CoordinateConverter: Add, Picture, % "x+m yp wp h-1 +Border +BackgroundTrans vGitHubGUI", % "HBITMAP:" ReadImages(CheckingFiles("File", False, "Base_Images.dll"), "GitHub1")
    funcObj := Func("Tray_links").Bind("GitHub")
    GuiControl CoordinateConverter: +g, GitHubGUI, %funcObj%
    ;--------------------------------------------------
    Gui, CoordinateConverter: Add, Text, % " x" CC_W*0.1 " ym w" CC_W*0.5 " +Center +Border +Section c" ColorText " hwndMainText", Window Properties 
    WinGetPos, MI_X, MI_Y, MI_W, MI_H, ahk_id %MainText%
    DDL_List := "Desktop||"
    for A_Loop, A_Key in fGetWindowsList()
        DDL_List .= A_Key.Exe " |"
    Gui, CoordinateConverter: Add, DDL, % " xp y+ w" MI_W " r10 +Sort vDDL_GUI gGUI_Handler hwndDDL_1", %DDL_List%
    ;--------------------------------------------------
    Gui, CoordinateConverter: Add, Text, % " xs y+ w" MI_W*0.2 " +Right +Border c" ColorText3, Width: `
    Gui, CoordinateConverter: Add, Text, % " x+ yp w" MI_W*0.3 " +Left +Border c" ColorText2 " vWP_Width",` %A_ScreenWidth%
    Gui, CoordinateConverter: Add, Text, % " x+ yP w" MI_W*0.2 " +Right +Border c" ColorText3, Height: `
    Gui, CoordinateConverter: Add, Text, % " x+ yp w" MI_W*0.3 " +Left +Border c" ColorText2 " vWP_Height",` %A_ScreenHeight%
    ;--------------------------------------------------
    Gui, CoordinateConverter: Add, Text, % " xs y+m w" MI_W*0.1 " +BackgroundTrans "
    Gui, CoordinateConverter: Add, GroupBox, % " xs-" FontSize " y+m w" MI_W+(FontSize*2) " r3 +Center Section c" ColorText,` Converter ` 
    Gui, CoordinateConverter: Add, Text, % " xp yp w" MI_W*0.1 " +BackgroundTrans "
    Gui, CoordinateConverter: Add, Text, % " xs+" FontSize " y+m w" MI_W*0.4 " +Center +Border c" ColorText, Сoordinates ; Coords
    Gui, CoordinateConverter: Add, Text, % " x+m yp w" MI_W*0.1 " +BackgroundTrans "
    Gui, CoordinateConverter: Add, Text, % " x+m yp w" MI_W*0.4 " +Center +Border c" ColorText, Multipliers ; Mulpls
    for A_Loop, A_Key in ["x1", "y1"] {
        Gui, CoordinateConverter: Add, Edit, % " xs+" FontSize " y+ w" MI_W*0.4 " h" MI_H " -TabStop +Center vCoords_" A_Key " gGUI_Handler"
        Gui, CoordinateConverter: Add, Text, % " x+m yp w" MI_W*0.1 " +Right +Border c" ColorText3, %A_Key%: `
        Gui, CoordinateConverter: Add, Edit, % " x+m yp w" MI_W*0.4 " h" MI_H " -TabStop +Center vMulpls_" A_Key " gGUI_Handler"
    }
    ;--------------------------------------------------
    Gui, CoordinateConverter: Add, Text, % " x" CC_W*0.65 " ym", 
    Gui, CoordinateConverter: Add, Checkbox, % " x+ Checked" CB_AlwaysOnTop " vCB_AlwaysOnTop gGUI_Handler" 
    Gui, CoordinateConverter: Add, Text, % " x+ w" CC_W*0.2 " +Left c" ColorText, Always on top
    ;--------------------------------------------------
    Gui, CoordinateConverter: Margin, 0, 0
    Gui, CoordinateConverter: Add, Picture, % "x0 y0 w"(A_ScreenWidth/3) " h-1", % "HBITMAP:" ReadImages(CheckingFiles("File", False, "Base_Images.dll"), "CoordinateConverterBG")

;;;;;;;;;; Start ;;;;;;;;;;
    OnMessage(0x111, "WM_COMMAND")
Return

;;;;;;;;;; Gui functions ;;;;;;;;;;
    GUI_Handler() {
        global
        local aVar
        static antiRecursion := antiRecursion ? antiRecursion : 1
        Gui, Submit, NoHide
        switch A_GuiControl {
            case "CB_AlwaysOnTop" : 
                StringReplace, aVar, %A_GuiControl%, ""
                WinSet, AlwaysOnTop , %aVar%, ahk_id %CoordinateConverter%
            case "DDL_GUI" :
                StringReplace, aVar, %A_GuiControl%, ""
                if (aVar = "Desktop") {
                        GuiControl, CoordinateConverter: Text, WP_Width, % "` " A_ScreenWidth
                        GuiControl, CoordinateConverter: Text, WP_Height, % "` " A_ScreenHeight
                        ActualWidth := A_ScreenWidth
                        ActualHeight := A_ScreenHeight
                        Return
                }
                aVar := fWinGetClientPos("ahk_exe " aVar)
                GuiControl, CoordinateConverter: Text, WP_Width  , % "` " aVar.w
                GuiControl, CoordinateConverter: Text, WP_Height , % "` " aVar.h
                ActualWidth := aVar.w
                ActualHeight := aVar.h
            case "Coords_x1", "Coords_y1", "Mulpls_x1", "Mulpls_y1" : {
                if TimePassed(antiRecursion) < 50
                    Return
                TimeStamp(antiRecursion)
                StringReplace, aVar, %A_GuiControl%, ""
                switch A_GuiControl {
                    case "Coords_x1" : GuiControl, CoordinateConverter: Text, Mulpls_x1, % FormatMultiplier(aVar / ActualWidth)
                    case "Coords_y1" : GuiControl, CoordinateConverter: Text, Mulpls_y1, % FormatMultiplier(aVar / ActualHeight)
                    case "Mulpls_x1" : GuiControl, CoordinateConverter: Text, Coords_x1, % Round(ActualWidth * aVar)
                    case "Mulpls_y1" : GuiControl, CoordinateConverter: Text, Coords_y1, % Round(ActualHeight * aVar)
                }   
            }
        }
        Return
    }

    fGetWindowsList() {
        List := []
        WinGet, Windows, List
        Loop %Windows% {
            Hwnd := Windows%A_Index%
            ; Только видимые окна
            if !DllCall("IsWindowVisible", "Ptr", Hwnd)
                Continue
            ; Без заголовка
            WinGetTitle, Title, ahk_id %Hwnd%
            if (Title = "")
                Continue
            ; Исключаем ToolWindow
            ExStyle := DllCall("GetWindowLong", "Ptr", Hwnd, "Int", -20, "Ptr")
            if (ExStyle & 0x80) ; WS_EX_TOOLWINDOW
                Continue
            ; Получаем exe
            WinGet, Exe, ProcessName, ahk_id %Hwnd%
            ; Класс
            WinGetClass, Class, ahk_id %Hwnd%
            ;--------------------------------------------------
            List.Push({"Hwnd" : Hwnd
                     , "Title" : Title
                     , "Exe" : Exe
                     , "Class" : Class})
        }
        return List
    }
    
    WM_COMMAND(wParam, lParam) {
        global DDL_1
        isMatch := False
        if (lParam != DDL_1)
            Return
        if ((wParam >> 16) = 7) { ; CBN_DROPDOWN
            GuiControlGet, SelectedExe, CoordinateConverter:, DDL_GUI
            DDL_List := "Desktop|"
            for A_Loop, A_Key in fGetWindowsList() {
                DDL_List .= A_Key.Exe "|"
                if (A_Key.Exe = SelectedExe)
                    isMatch := True
            }
            GuiControl, CoordinateConverter:, DDL_GUI, |%DDL_List%  
            if isMatch {
                GuiControl, CoordinateConverter: ChooseString, DDL_GUI, %SelectedExe%
            } Else {
                GuiControl, CoordinateConverter: ChooseString, DDL_GUI, Desktop
                GuiControl, CoordinateConverter: Text, WP_Width, % "` " A_ScreenWidth
                GuiControl, CoordinateConverter: Text, WP_Height, % "` " A_ScreenHeight
                ActualWidth := A_ScreenWidth
                ActualHeight := A_ScreenHeight
            }
        }
    }

;;;;;;;;;; Coordinate Converter ;;;;;;;;;;
    FormatMultiplier(Value) {
        Value := Round(Value, 4)
        Parts := StrSplit(Value, ".")
        if (Parts.Count() = 1)
            return Parts[1] ".0000"
        while (StrLen(Parts[2]) < 4)
            Parts[2] .= "0"
        return Parts[1] "." SubStr(Parts[2], 1, 4)
    }    

;;;;;;;;;; Exit ;;;;;;;;;;
    CoordinateConverterGuiClose() {
        ExitApp
    }