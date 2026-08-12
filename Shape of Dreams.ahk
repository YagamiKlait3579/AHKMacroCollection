;;;;;;;;;; Loading ;;;;;;;;;;
    #include %A_Scriptdir%\libs\CoreLibsFor_AHK\BaseLibs\Header.ahk
    ;--------------------------------------------------
    #IfWinActive, Shape of Dreams
    global PWN := "Shape of Dreams" ; Program window name
    CheckForUpdates("YagamiKlait3579", "AHKMacroCollection", "main", CheckingFiles("File", False, "Header.ahk"))
    OnExit("BeforeExiting")

;;;;;;;;;; Info ;;;;;;;;;;
    /*
        Скрипт предназначен для автоматического последовательного использования выбранных способностей
        в игре Shape of Dreams.

        При удержании клавиши StartKey скрипт по очереди нажимает клавиши способностей, которые включены
        в интерфейсе. Для каждой способности можно отдельно включить или отключить автоматическое использование.

        Сочетание EditStatusKey + клавиша способности позволяет быстро включать и отключать её автоматическое использование.
        Текущее состояние выбранных способностей сохраняется и восстанавливается при следующем запуске скрипта.

        Запустите скрипт после запуска игры. Для работы скрипта окно игры должно быть активно.

        Все основные настройки изменяются ниже в разделе Setting. Также часть общих настроек находится
        в файле Settings.ahk. Если одна и та же настройка указана и здесь, и в Settings.ahk,
        значение из этого проекта имеет приоритет.
    */

;;;;;;;;;; Setting ;;;;;;;;;;
    AbilityA_Key    = 1       ; Способность 1
    AbilityB_Key    = 2       ; Способность 2
    AbilityC_Key    = e       ; Способность 3
    AbilityD_Key    = r       ; Способность 4
    ;--------------------------------------------------
    EditStatusKey   = Alt     ; Включает/выключает повторение способности при нажатии этой клавиши вместе с клавишей способности
    KeyDelay       := 25      ; Пауза между нажатиями клавиш (ms.)
    ;--------------------------------------------------
    GuiPositionX   := 0.1650  ; Изменение положения интерфейса по горизнтали (X-координата) только для этого скрипта
    GuiPositionY   := 0.9400  ; Изменение положения интерфейса по вертикали (Y-координата) только для этого скрипта

;;;;;;;;;; Variables ;;;;;;;;;;
    if !CheckingFiles("File", True, "SavedSettings.ini")
        FileAppend, , % A_WorkingDir . "\libs\SavedSettings.ini"
    LoadIniSection(CheckingFiles("File", True, "SavedSettings.ini"), SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1))
    ;--------------------------------------------------
    gNameKey := [AbilityA_Key, AbilityB_Key, AbilityC_Key, AbilityD_Key]
    global gStatusKey := []
    for A_Loop, A_key in [AbilityA_Status, AbilityB_Status, AbilityC_Status, AbilityD_Status]
        gStatusKey.Push(A_key ? A_key : 0)

;;;;;;;;;; Hotkeys ;;;;;;;;;;
    Hotkey, *%StartKey%, Main

    for A_Loop, A_key in [AbilityA_Key, AbilityB_Key, AbilityC_Key, AbilityD_Key] {
        fHotkey := Func("SwitchKey").Bind(A_Loop)
        Hotkey, %EditStatusKey% & %A_key%, %fHotkey%
    } 

;;;;;;;;;; Gui ;;;;;;;;;;
    UpdateDGP({"Transparency" : gTransparency, "Blur" : gBlur, "Scale" : gInterfaceScale})
    GuiInGame("Start", "MainInterface")
        Gui, MainInterface: Add, Text, xm ym +Center HwndT1, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1)
        Gui, MainInterface: Add, Text, x+m +Center +Border cRed vScriptStatus_Gui HwndT2,` Disabled ` ; Enabled
        ;--------------------------------------------------
        A_Width := ((fGuiSize(T1, T2).w - (DGP.Margin.1 * 3)) / 4)
        Gui, MainInterface: Add, Text, % "xm y+m w" A_Width " +Center +Border c" (gStatusKey[1] ? "Lime" : "Red") " vAbility1", %AbilityA_Key%
        Gui, MainInterface: Add, Text, % "x+m w" A_Width " +Center +Border c" (gStatusKey[2] ? "Lime" : "Red") " vAbility2", %AbilityB_Key%
        Gui, MainInterface: Add, Text, % "x+m w" A_Width " +Center +Border c" (gStatusKey[3] ? "Lime" : "Red") " vAbility3", %AbilityC_Key%
        Gui, MainInterface: Add, Text, % "x+m w" A_Width " +Center +Border c" (gStatusKey[4] ? "Lime" : "Red") " vAbility4", %AbilityD_Key%
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
        GuiControl, % "MainInterface: +c" (gStatusKey[key] ? "Lime" : "Red") " +Redraw", % "Ability" key
    }

;;;;;;;;;; Scripts ;;;;;;;;;;
    Main() {
        global
        GuiInGame("Edit", "MainInterface", {"id" : "ScriptStatus_Gui", "Color" : "Lime", "Text" : "Enabled"})
        While GetKeyState(StartKey, "p") {
            for A_Loop, A_key in gStatusKey
                if A_key {
                    Send, % "{Blind}{" gNameKey[A_Loop] " Down} "
                    lSleep(KeyDelay)
                    Send, % "{Blind}{" gNameKey[A_Loop] " Up} "
                    lSleep(KeyDelay)
                }
        }
        GuiInGame("Edit", "MainInterface", {"id" : "ScriptStatus_Gui", "Color" : "Red", "Text" : "Disabled"})
    }

;;;;;;;;;; Exit ;;;;;;;;;;
    BeforeExiting() {
        global
        for A_Loop, A_key in ["AbilityA_Status", "AbilityB_Status", "AbilityC_Status", "AbilityD_Status"]
            IniWrite, % gStatusKey[A_Loop] , %OP_SavedSettings%, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1), %A_key%
    }