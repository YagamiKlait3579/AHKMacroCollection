;;;;;;;;;; Loading ;;;;;;;;;;
    #include %A_Scriptdir%\libs\CoreLibsFor_AHK\BaseLibs\Header.ahk
    ;--------------------------------------------------
    #IfWinActive, Gunfire Reborn
    global PWN := "Gunfire Reborn" ; Program window name
    CheckForUpdates("YagamiKlait3579", "AHKMacroCollection", "main", CheckingFiles("File", False, "Header.ahk"))
    OnExit("BeforeExiting")

;;;;;;;;;; Info ;;;;;;;;;;
    /*
        Скрипт для автоматизации некоторых действий в Gunfire Reborn.

        Скрипт позволяет автоматически повторять выбранные действия персонажа:
        • Q / E — повторное использование соответствующих способностей.
        • Shift — автоматическое выполнение рывка.
        • Jump — автоматическое нажатие прыжка.

        Дополнительно доступны специальные функции:
        • AoBai — стрелба из двух орудий в ульте.
        • RadioactiveGauntlet — автоматическое продление усиленя этого оружия.
        • ChromaticMagazine — постоянная повторная активация этой руны.

        Для каждой основной клавиши можно отдельно включить или выключить автоматическое
        повторение. Дополнительные функции можно переключать между собой, либо полностью
        отключить.

        Режим работы скрипта переключается клавишей WorkingMethodKey:
        • Clamp — автоматизация работает только пока удерживается StartKey.
        • On \ Off — StartKey включает и выключает автоматизацию.

        Клавиша EditStatusKey используется вместе с клавишами способностей для включения
        или выключения их автоматического повторения. При её удержании также можно переключать
        дополнительные функции клавишами IncreaseKey / DecreaseKey.

        Запускайте скрипт после запуска игры. Перед использованием проверьте настройки
        клавиш в блоке Setting и при необходимости измените их под свою раскладку.

        Из-за особенностей игрового движка для корректного срабатывания клавиши рывка
        рекомендуется дополнительно назначить рывок в настройках игры на любую другую
        клавишу, которая не является клавишей-модификатором (Shift, Alt, Ctrl и т.п.),
        и указать эту клавишу в настройке ShiftB_Key.

        Общие настройки интерфейса и скриптов находятся в файле Settings.ahk.
        Если какая-либо настройка указана одновременно в этом файле и в данном проекте,
        настройка из проекта имеет приоритет.
    */

;;;;;;;;;; Setting ;;;;;;;;;;
    WorkingMethodKey  = End       ; Переключает режим работы StartKey между удержанием и переключением (вкл/выкл)
    EditStatusKey     = Alt       ; Включает/выключает повторение способности при нажатии этой клавиши вместе с клавишей способности
    ; Также только при удержании этой клавиши работает переключение доп.функции клавишами IncreaseKey и DecreaseKey
    IncreaseKey      = WheelUp    ; Следующая дополнительная функция в списке
    DecreaseKey      = WheelDown  ; Предыдущая дополнительная функция в списке
    ;--------------------------------------------------
    GuiPositionX     := 0.4400    ; Изменение положения интерфейса по горизнтали (X-координата) только для этого скрипта
    GuiPositionY     := 0.9425    ; Изменение положения интерфейса по вертикали (Y-координата) только для этого скрипта

    ;;;;; In-game settings (Настройки в игре);;;;;
    AbilityA_Key      = e         ; Основная способность
    AbilityB_Key      = q         ; Дополнительная способность
    ShiftA_Key        = Shift     ; Ваша клавиша рывка
    ShiftB_Key        = F9        ; Альтернативная клавиша рывка для скрипта
    Jump_Key          = Space     ; Прыжок
    ReloadKey         = r         ; Перезарядка

;;;;;;;;;; Variables ;;;;;;;;;;
    if !CheckingFiles("File", True, "SavedSettings.ini")
        FileAppend, , % A_WorkingDir . "\libs\SavedSettings.ini"
    LoadIniSection(CheckingFiles("File", True, "SavedSettings.ini"), SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1))
    ;--------------------------------------------------
    gNameKey := [AbilityB_Key, AbilityA_Key, ShiftB_Key, Jump_Key]
    global gStatusKey := []
    for A_Loop, A_key in [AbilityB_Status, AbilityA_Status, Shift_Status, Jump_Status]
        gStatusKey.Push(A_key ? A_key : 0)
    ;--------------------------------------------------
    FunctionList := ["AoBai","RadioactiveGauntlet", "ChromaticMagazine"]
    gFunctions := {}
    Loop, % FunctionList.Count()
        gFunctions.InsertAt(A_Index, Func(FunctionList[A_Index]))
    global A_Function := A_Function ? A_Function : 0
    ;--------------------------------------------------
    global WorkingMethod := WorkingMethod ? WorkingMethod : 0
    global A_ScriptStatus

;;;;;;;;;; Hotkeys ;;;;;;;;;;
    Hotkey, *%StartKey%, Main

    Hotkey, *%WorkingMethodKey%, SwitchWorkingMethod
    
    for A_Loop, A_key in [AbilityB_Key, AbilityA_Key, ShiftA_Key, Jump_Key] {
        fHotkey := Func("SwitchKey").Bind(A_Loop)
        Hotkey, %EditStatusKey% & %A_key%, %fHotkey%
    } 
    for A_Loop, A_key in [IncreaseKey, DecreaseKey] {
        fHotkey := Func("SwitchFunctions").Bind(A_Loop)
        Hotkey, %EditStatusKey% & %A_key%, %fHotkey%
    } 
    fHotkey := ""

;;;;;;;;;; Gui ;;;;;;;;;;
    PlaceForTheText := " Functions "
    ;--------------------------------------------------
    UpdateDGP({"Transparency" : gTransparency, "Blur" : gBlur, "Scale" : gInterfaceScale, "BorderColor" : "E6C44F", "BorderSize" : 2})
    GuiInGame("Start", "MainInterface")
        Gui, MainInterface: Add, Text, xm ym +Right vT1_1, %PlaceForTheText%
        GuiControl, MainInterface: Text, T1_1, Keys:
        for A_Loop, A_key in [" Q ", " E ", "  Shift  ", "  Jump  "]
            Gui, MainInterface: Add, Text, % " x+m +Border +c" (gStatusKey[A_Loop] ? "Lime" : "Red") " vGui_Ability" A_Loop " HwndGui_Ability" A_Loop , %A_key%
        ;--------------------------------------------------
        Gui, MainInterface: Add, Text, xm y+m +Right vT2_1, %PlaceForTheText%
        GuiControl, MainInterface: Text, T2_1, Settings:
        A_Width := ((fGuiSize(Gui_Ability1, Gui_Ability4).w - DGP.Margin.1) / 2)
        Gui, MainInterface: Add, Text, x+m w%A_Width% +Border +Center cYellow vWorkingMethod_Gui, % WorkingMethod ? "On \ Off" : "Clamp" 
        Gui, MainInterface: Add, Text, x+m w%A_Width% +Border +Center cRed vScriptStatus_Gui,` Disabled `
        ;--------------------------------------------------
        Gui, MainInterface: Add, Text, xm y+m +Right vT3_1, %PlaceForTheText%
        GuiControl, MainInterface: Text, T3_1, Functions:
        A_Width := fGuiSize(Gui_Ability1, Gui_Ability4).w
        Gui, MainInterface: Add, Text, % " x+m w" A_Width " +Center +Border c" (A_Function ? "Lime" : "Red") " vGui_Function", % A_Function ? FunctionList[A_Function] : "Off"
    GuiInGame("End", "MainInterface", {"ratio" : [GuiPositionX,GuiPositionY]})
    fSuspendGui("On", "MainInterface")
    if DebugGui
        fDebugGui("Create", MainInterface)
    if HideTheInterface
        SetTimer, ShowHideGui , 250, -1
Return

;;;;;;;;;; Control Functions ;;;;;;;;;;
    SwitchKey(key) {
        global
        gStatusKey[key] := !gStatusKey[key]
        GuiControl, % "MainInterface: +c" (gStatusKey[key] ? "Lime" : "Red") " +Redraw", % "Gui_Ability" key
    }

    SwitchWorkingMethod() {
        global
        WorkingMethod := !WorkingMethod
        GuiControl, MainInterface: Text, WorkingMethod_Gui, % WorkingMethod ? "On \ Off" : "Clamp" 
    }

    SwitchFunctions(param) {
        global
        switch param {
            case 1 : A_Function := A_Function + 1 > FunctionList.Count() ? 0 : A_Function += 1
            case 2 : A_Function := A_Function - 1 < 0 ? FunctionList.Count() : A_Function -= 1
        }
        GuiControl, MainInterface: Text, Gui_Function, % A_Function ? FunctionList[A_Function] : "Off"
        GuiControl, % "MainInterface: +c" (A_Function ? "Lime" : "Red") " +Redraw", Gui_Function
    }

    ScriptStatus(param = "") {
        global
        if param in 1,True,On,Start
            A_ScriptStatus := 1
        else if param in 0,False,Off,Stop
            A_ScriptStatus := 0
        else
            A_ScriptStatus := !A_ScriptStatus
        GuiControl, MainInterface: Text, ScriptStatus_Gui, % A_ScriptStatus ? "Enabled" : "Disabled"
        GuiControl, % "MainInterface: +c" (A_ScriptStatus ? "Lime" : "Red") " +Redraw", ScriptStatus_Gui
        Return A_ScriptStatus
    }

;;;;;;;;;; Scripts ;;;;;;;;;;
    Main() {
        global
        if WorkingMethod {
            if ScriptStatus()
                SetTimer, GunfireReborn, -1
        } Else if !A_ScriptStatus {
            ScriptStatus("Start")
            GunfireReborn()
        }
    }

    GunfireReborn() {
        global
        while (WorkingMethod && A_ScriptStatus) || GetKeyState(StartKey, "p") {
            TimeStamp(A_Stamp)
            for A_Loop, A_key in gStatusKey
                if A_key {
                    fSendIfWinActive(gNameKey[A_Loop])
                    Sleep, 1
                }
                if A_Function
                    gFunctions[A_Function].call()
                fDebugGui("Edit", "Cycle time", TimePassed(A_Stamp) " ms")
        }
        ScriptStatus("Stop")
    }

;;;;;;;;;; Functions for the game ;;;;;;;;;;
    AoBai() {
        global
        IfWinActive, %PWN%
            fMouseInput("Left"), fMouseInput("Right")
    }

    RadioactiveGauntlet() {
        global
        local GameWindow := fWinGetClientPos(PWN)
        local RG := {"x1" : Round(GameWindow.x + (GameWindow.w * 0.4568))
                    ,"y1" : Round(GameWindow.y + (GameWindow.h * 0.4907))
                    ,"x2" : Round(GameWindow.x + (GameWindow.w * 0.4609))
                    ,"y2" : Round(GameWindow.y + (GameWindow.h * 0.5093))}
        PixelSearch,,, RG.x1, RG.y1, RG.x2, RG.y2, "0xd4d4d4", 10, Fast RGB
            if !ErrorLevel
                IfWinActive, %PWN%
                    Loop, 3
                        fMouseInput("Right", 10) 
    }

    ChromaticMagazine() {
        global
        AoBai(), fSendIfWinActive(ReloadKey)
    }

;;;;;;;;;; Exit ;;;;;;;;;;
    BeforeExiting() {
        global
        for A_Loop, A_key in ["AbilityB_Status", "AbilityA_Status", "Shift_Status", "Jump_Status"]
            IniWrite, % gStatusKey[A_Loop] , %OP_SavedSettings%, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1), %A_key%
        IniWrite, %WorkingMethod%, %OP_SavedSettings%, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1), WorkingMethod
        IniWrite, %A_Function%, %OP_SavedSettings%, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1), A_Function
    }