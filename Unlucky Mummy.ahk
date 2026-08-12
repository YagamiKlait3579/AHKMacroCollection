;;;;;;;;;; Loading ;;;;;;;;;;
    #include %A_Scriptdir%\libs\CoreLibsFor_AHK\BaseLibs\Header.ahk
    ;--------------------------------------------------
    #IfWinActive, ahk_exe UnluckyMummy.exe
    global PWN := "ahk_exe UnluckyMummy.exe" ; Program window name
    CheckForUpdates("YagamiKlait3579", "AHKMacroCollection", "main", CheckingFiles("File", False, "Header.ahk"))

;;;;;;;;;; Info ;;;;;;;;;;
    /* 
        Этот скрипт предназначен для автоматизации игрового процесса в Unlucky Mummy.
        После запуска автоматизации он самостоятельно собирает реликвии и котов, 
        открывает основной ящик и покупает доступные улучшения.
        
        Для правильной работы скрипта игра Unlucky Mummy должна быть запущена до запуска скрипта.
        
        Автоматизация активируется назначенной в общих настройках клавишей `StartKey`.
        
        Также используются общие настройки, расположенные в файле `Settings.ahk`. 
        Если какая-либо настройка одновременно присутствует в `Settings.ahk` и в этом проекте, 
        настройка, указанная непосредственно в данном проекте, имеет приоритет.

    */

;;;;;;;;;; Setting ;;;;;;;;;;
    ; True — вкл, False — выкл.
    RelicsAndCats         := True         ; Собирать реликвии и котов
    Upgrade_Chance        := True         ; Улучшать шанс открытия реликвий 
    Upgrade_Relics        := True         ; Улучшать уровень реликвий
    Upgrade_CatRune       := True         ; Улучшать руну кота
    Upgrade_MainKey       := True         ; Улучшать скорость открытия
    Upgrade_PassiveIncome := True         ; Улучшать 
    ;--------------------------------------------------
    TestAllGuiKey          = F1           ; Показать зону поиска ключей 
    HideTheInterface      := True         ; Скрывать интерфейс при сворачивании игры (True — скрывать, False — не скрывать)
    GuiPositionX          := 0.1800       ; Положение интерфейса по горизонтали (X-координата)
    GuiPositionY          := 0.8200       ; Положение интерфейса по вертикали (Y-координата)

;;;;;;;;;; Variables ;;;;;;;;;;
    global a_Status := False
    global mainCoords, RelicsCoords
    ;--------------------------------------------------                 
    MainSymbol :="|<>00FF00-0.86$23.07U00DU00T000y001w003s007k00DU00T000y0Dzzzzzzzzzzzzzzw0S000w001s003k007U00D000S000w001s0E"

;;;;;;;;;; Hotkeys ;;;;;;;;;;
    Hotkey, *%StartKey%, Main
    Hotkey, *%TestAllGuiKey%, TestAllGui

;;;;;;;;;; Gui ;;;;;;;;;;
    PlaceForTheText := "Text Text "
    ;--------------------------------------------------
    UpdateDGP({"Transparency" : gTransparency, "Blur" : gBlur, "Scale" : gInterfaceScale})
    GuiInGame("Start", "MainInterface")
        Gui, MainInterface: Add, Text, xm ym +Center, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1)
        Gui, MainInterface: Add, Text, x+m +Center +Border cRed vT1,` Disabled ` ; Enabled
    GuiInGame("End", "MainInterface", {"ratio" : [GuiPositionX,GuiPositionY]})
    fSuspendGui("On", "MainInterface")
    if DebugGui
        fDebugGui("Create", MainInterface)
    if HideTheInterface
        SetTimer, ShowHideGui , 250, -1
Return

;;;;;;;;;; Scripts ;;;;;;;;;;
    Main() {
        global
        a_Status := !a_Status
        if a_Status
            SetTimer, AutoGame, -1
        GuiInGame("Edit", "MainInterface", {"id" : "T1", "Color" : (a_Status ? "Lime" : "Red"), "Text" : (a_Status ? "Enabled" : "Disabled")})        
    }

    AutoGame() {
        global
        local A_Loop, A_key
        local A_Stamp := 1
        local FT_mX, FT_mY, FT_A_Text := 0.25
        local a_MousePause := 100
        CoordsInitialization()
        local VoidMouse_X := Round((WindowProperties.w - WindowProperties.x) * 0.7500)
        local VoidMouse_Y := Round((WindowProperties.h - WindowProperties.y) * 0.5000)
        While a_Status {
            if ((TimePassed(A_Stamp) > 200) && Checking_MainKey(mainCoords.MainKey, "e1853f", 5)) {
                if RelicsAndCats 
                    For A_Loop, A_key in RelicsCoords
                        fMouseClick(A_key[1], A_key[2])
                Send, {Blind}{Space}
                TimeStamp(A_Stamp)
            } Else if (TimePassed(A_Stamp) > 2000) {
                For A_Loop, A_key in RelicsCoords
                            fMouseClick(A_key[1], A_key[2])
                TimeStamp(A_Stamp)
            }
        if Upgrade_Chance
            Loop, 
                if FindText(FT_mX, FT_mY, mainCoords.Chance[1], mainCoords.Chance[2], mainCoords.Chance[3], mainCoords.Chance[4], FT_A_Text, FT_A_Text, MainSymbol) {
                    fMouseClick(FT_mX, FT_mY)
                    lSleep(a_MousePause)
                    fMouseClick(VoidMouse_X, VoidMouse_Y)
                } Else
                    Break
        if Upgrade_Relics
            Loop, 
                if FindText(FT_mX, FT_mY, mainCoords.UpgradeRelics[1], mainCoords.UpgradeRelics[2], mainCoords.UpgradeRelics[3], mainCoords.UpgradeRelics[4], FT_A_Text, FT_A_Text, MainSymbol) {
                    fMouseClick(FT_mX, FT_mY)
                    lSleep(a_MousePause)
                    fMouseClick(VoidMouse_X, VoidMouse_Y)
                } Else
                    Break
        if Upgrade_CatRune
            Loop, 
                if FindText(FT_mX, FT_mY, mainCoords.CatRune[1], mainCoords.CatRune[2], mainCoords.CatRune[3], mainCoords.CatRune[4], FT_A_Text, FT_A_Text, MainSymbol) {
                    fMouseClick(FT_mX, FT_mY)
                    lSleep(a_MousePause)
                    fMouseClick(VoidMouse_X, VoidMouse_Y)
                } Else
                    Break
        if Upgrade_PassiveIncome
            Loop, 
                if FindText(FT_mX, FT_mY, mainCoords.PassiveIncome[1], mainCoords.PassiveIncome[2], mainCoords.PassiveIncome[3], mainCoords.PassiveIncome[4], FT_A_Text, FT_A_Text, MainSymbol) {
                    fMouseClick(FT_mX, FT_mY)
                    lSleep(a_MousePause)
                    fMouseClick(VoidMouse_X, VoidMouse_Y)
                } Else
                    Break
        if Upgrade_MainKey
            Loop, 
                if FindText(FT_mX, FT_mY, mainCoords.UpgradeMainKey[1], mainCoords.UpgradeMainKey[2], mainCoords.UpgradeMainKey[3], mainCoords.UpgradeMainKey[4], FT_A_Text, FT_A_Text, MainSymbol) {
                    fMouseClick(FT_mX, FT_mY)
                    lSleep(a_MousePause)
                    fMouseClick(VoidMouse_X, VoidMouse_Y)
                } Else
                    Break
        }
    }

;;;;;;;;;; Functions ;;;;;;;;;; 
    CoordsInitialization() {
        global
        WindowProperties := fWinGetClientPos(PWN)  
        mainCoords := {"MainKey"        : [Round(WindowProperties.x + (WindowProperties.w * 0.4428)), Round(WindowProperties.y + (WindowProperties.h* 0.8335)) 
                                          ,Round(WindowProperties.x + (WindowProperties.w * 0.4533)), Round(WindowProperties.y + (WindowProperties.h* 0.8428))]
                      ,"Chance"         : [Round(WindowProperties.x + (WindowProperties.w * 0.5262)), Round(WindowProperties.y + (WindowProperties.h* 0.0557)) 
                                          ,Round(WindowProperties.x + (WindowProperties.w * 0.5444)), Round(WindowProperties.y + (WindowProperties.h* 0.0928))]
                      ,"UpgradeMainKey" : [Round(WindowProperties.x + (WindowProperties.w * 0.5495)), Round(WindowProperties.y + (WindowProperties.h* 0.8197)) 
                                          ,Round(WindowProperties.x + (WindowProperties.w * 0.5705)), Round(WindowProperties.y + (WindowProperties.h* 0.8615))]
                      ,"UpgradeRelics"  : [Round(WindowProperties.x + (WindowProperties.w * 0.1825)), Round(WindowProperties.y + (WindowProperties.h* 0.8565)) 
                                          ,Round(WindowProperties.x + (WindowProperties.w * 0.8230)), Round(WindowProperties.y + (WindowProperties.h* 0.9910))]
                      ,"CatRune"        : [Round(WindowProperties.x + (WindowProperties.w * 0.3828)), Round(WindowProperties.y + (WindowProperties.h* 0.0787)) 
                                          ,Round(WindowProperties.x + (WindowProperties.w * 0.4010)), Round(WindowProperties.y + (WindowProperties.h* 0.1065))]
                      ,"PassiveIncome"  : [Round(WindowProperties.x + (WindowProperties.w * 0.5833)), Round(WindowProperties.y + (WindowProperties.h* 0.0787)) 
                                          ,Round(WindowProperties.x + (WindowProperties.w * 0.6016)), Round(WindowProperties.y + (WindowProperties.h* 0.1065))]}
        RelicsCoords := [[Round(WindowProperties.x + (WindowProperties.w * 0.4245)), Round(WindowProperties.y + (WindowProperties.h * 0.3611))]
                        ,[Round(WindowProperties.x + (WindowProperties.w * 0.4479)), Round(WindowProperties.y + (WindowProperties.h * 0.5463))]
                        ,[Round(WindowProperties.x + (WindowProperties.w * 0.4479)), Round(WindowProperties.y + (WindowProperties.h * 0.6574))] 
                        ,[Round(WindowProperties.x + (WindowProperties.w * 0.5469)), Round(WindowProperties.y + (WindowProperties.h * 0.5741))]
                        ,[Round(WindowProperties.x + (WindowProperties.w * 0.4844)), Round(WindowProperties.y + (WindowProperties.h * 0.4630))]
                        ,[Round(WindowProperties.x + (WindowProperties.w * 0.4948)), Round(WindowProperties.y + (WindowProperties.h * 0.3241))]
                        ,[Round(WindowProperties.x + (WindowProperties.w * 0.4948)), Round(WindowProperties.y + (WindowProperties.h * 0.2037))]
                        ,[Round(WindowProperties.x + (WindowProperties.w * 0.5521)), Round(WindowProperties.y + (WindowProperties.h * 0.2500))]]   
    }

    Checking_MainKey(coords, color, A_color, amount = 5) {
        Loop, %amount% {
            PixelSearch,,, coords[1], coords[2], coords[3], coords[4], "0x"color, A_color, Fast RGB
            if !ErrorLevel
                Return 1
        }
        Return 0
    }

    TestAllGui() {
        global
        local A_Loop, A_key
        static B_Gui
        B_Gui := !B_Gui
        CoordsInitialization()
        if B_Gui {
            fBorder("MainKey"       , {"Coords" : mainCoords.MainKey        , "Color" : "Fuchsia", "Size" : 2})
            fBorder("Chance"        , {"Coords" : mainCoords.Chance         , "Color" : "Fuchsia", "Size" : 2})
            fBorder("UpgradeMainKey", {"Coords" : mainCoords.UpgradeMainKey , "Color" : "Fuchsia", "Size" : 2})
            fBorder("UpgradeRelics" , {"Coords" : mainCoords.UpgradeRelics  , "Color" : "Fuchsia", "Size" : 2})
            fBorder("CatRune"       , {"Coords" : mainCoords.CatRune        , "Color" : "Fuchsia", "Size" : 2})
            fBorder("PassiveIncome" , {"Coords" : mainCoords.PassiveIncome  , "Color" : "Fuchsia", "Size" : 2})
            for A_Loop, A_key in RelicsCoords
                fBorder("RelicsCoords" A_Loop, {"Coords" : [A_key[1]-5, A_key[2]-5, A_key[1]+5, A_key[2]+5], "Color" : "Fuchsia", "Size" : 2})                
        } Else {
            fBorder("MainKey"       , "Destroy")
            fBorder("Chance"        , "Destroy")
            fBorder("UpgradeMainKey", "Destroy")
            fBorder("UpgradeRelics" , "Destroy")
            fBorder("CatRune"       , "Destroy")
            fBorder("PassiveIncome" , "Destroy")
            loop, % RelicsCoords.Count()
                fBorder("RelicsCoords" A_Index, "Destroy")
        }
    }