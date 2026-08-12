;;;;;;;;;; Loading ;;;;;;;;;;
    #include %A_Scriptdir%\libs\CoreLibsFor_AHK\BaseLibs\Header.ahk
    ;--------------------------------------------------
    #IfWinActive, ahk_exe League of Legends.exe
    ;global PWN := "" ; Program window name
    CheckForUpdates("YagamiKlait3579", "AHKMacroCollection", "main", CheckingFiles("File", False, "Header.ahk"))
    OnExit("BeforeExiting")

;;;;;;;;;; Info ;;;;;;;;;;
    /*
        League of Legends - Chat Helper

        Программа предназначена для быстрого отправления заранее подготовленных
        сообщений во время игры в League of Legends.

        В программе можно сохранить до 20 сообщений, каждому из которых можно
        задать собственное название. Во время игры достаточно удерживать
        назначенную клавишу, выбрать нужное сообщение в Overlay и отпустить клавишу.
        Программа автоматически откроет игровой чат, при необходимости переключит
        его в общий чат (/all), отправит сообщение и закроет чат.

        Если сообщение длиннее установленного в игре лимита (125 символов),
        программа автоматически разбивает его на несколько сообщений. При этом
        она старается не разделять слова и выбирает естественные места для
        разрыва текста: сначала конец предложения (. ! ?), затем другие знаки
        препинания (, ; :) и только после этого обычный пробел.

        Настройки сообщений можно изменять в окне программы. Доступны импорт и
        экспорт сообщений в INI-файл, поэтому набор подготовленных сообщений
        можно переносить между компьютерами или сохранять как резервную копию.

        Также можно выбрать режим чата (ALL или TEAM) и включить небольшой
        Overlay, который показывает, что программа запущена.

        Также существует общий файл Settings.ahk с настройками, используемыми
        другими проектами. Если какая-либо настройка задана и здесь, и в
        Settings.ahk, значение, указанное непосредственно в этом проекте,
        имеет приоритет.
    */

;;;;;;;;;; Setting ;;;;;;;;;;
    ; Клавиша указываются в нижнем регистре (без использования Shift или CapsLock).
    ; Правильное написание клавиш можно посмотреть тут: https://ahk-wiki.ru/keylist
    StartKey          = sc0x29    ; Клавиша открытия меню скрипта в игре (SC0x29 это буква Ё, независимо от раскладки языка)
    ;--------------------------------------------------
    gColor           := "ff7d19"  ; Цвет текста в оверлее игры (цвет в HEX формате)
    gInterfaceScale  := 100       ; Масштаб текста в оверлее игры в процентах
    ;--------------------------------------------------
    GuiPositionX     := 0.0125    ; Изменение положения интерфейса по горизнтали (X-координата) только для этого скрипта
    GuiPositionY     := 0.9800    ; Изменение положения интерфейса по вертикали (Y-координата) только для этого скрипта

;;;;;;;;;; Variables ;;;;;;;;;;
    if !CheckingFiles("File", True, "SavedSettings.ini")
        FileAppend, , % A_WorkingDir . "\libs\SavedSettings.ini"
    LoadIniSection(CheckingFiles("File", True, "SavedSettings.ini"), SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1))
    ;--------------------------------------------------
    if (!CheckingFiles("File", True, "LolChat.ini"))
        FileAppend, , % A_WorkingDir . "\libs\LolChat.ini"
    LoadIniSection(CheckingFiles("File", True, "LolChat.ini"), "All")
    ;--------------------------------------------------
    StartKey       := StartKey ? StartKey : "sc0x29"
    ChatSettings   := ChatSettings ? ChatSettings : False
    CB_ShowOverlay := CB_ShowOverlay ? CB_ShowOverlay : False
    SelectedSlot   := SelectedSlot ? SelectedSlot : 1

;;;;;;;;;; Hotkeys ;;;;;;;;;;
    Hotkey, *%StartKey%, Main
    Hotkey, *%SuspendKey%, SuspendScript, Off

;;;;;;;;;; Gui ;;;;;;;;;;
    Launcher() 
    Overlay("Start")
    if CB_ShowOverlay
        Overlay("MiniOverlayShow")
Return

;;;;;;;;;; Gui functions ;;;;;;;;;;
    GUI_Handler() {
        global
        Gui, Submit, NoHide
        local aVar, localHK
        switch A_GuiControl {
            Default :
                if !RegExMatch(A_GuiControl, "^Key(\d+)$", Match)
                    Return
                switch A_Gui {
                    case "LauncherGUI" :
                        SelectedSlot := Match1
                        Loop, 20
                            GuiInGame("Edit", "LauncherGUI", {"id" : "Key" A_Index, "Color" : (A_Index = Match1 ? "Lime" : "Red")})
                            GuiInGame("Edit", "LauncherGUI", {"id" : "EditTitle", "Text" : (gTitle%SelectedSlot% ? gTitle%SelectedSlot% : " ")})
                            GuiInGame("Edit", "LauncherGUI", {"id" : "EditText" , "Text" : (gText%SelectedSlot% ? gText%SelectedSlot% : " ")})
                    case "Overlay" :
                        ChoiceWaiting := False
                        Overlay("Hide")
                        WinActivate, ahk_exe League of Legends.exe
                        RegExMatch(A_GuiControl, "^Key(\d+)$", Match)
                        local aText := gText%Match1%
                        local A_Loop, A_key
                        for A_Loop, A_key in fSplitText(aText, 125) {
                            lSleep(50)
                            Send, {Enter}
                            lSleep(50)
                            if ChatSettings
                                Send, /all `
                            SendRaw, %A_key%
                            lSleep(50)
                            Send, {Enter}
                        }
                }
            case "KeySave" :
                if (!EditTitle || (EditTitle = " "))  {
                    MsgBox, 262160, League of Legends - Chat Helper, Заголовок сообщения не указан! `nThe message title is not specified!
                    Return
                }
                if (!EditText || (EditText = " ")) {
                    MsgBox, 262160, League of Legends - Chat Helper, Текст сообщения не указан! `nThe text of the message is not specified!
                    Return
                }
                gTitle%SelectedSlot% := EditTitle
                gText%SelectedSlot%  := EditText
                Overlay("Update")
            case "KeyCancel" :
                GuiInGame("Edit", "LauncherGUI", {"id" : "EditTitle", "Text" : (gTitle%SelectedSlot% ? gTitle%SelectedSlot% : " ")})
                GuiInGame("Edit", "LauncherGUI", {"id" : "EditText" , "Text" : (gText%SelectedSlot% ? gText%SelectedSlot% : " ")})
            case "EditTitle", "EditText" : Return
            case "chatAll", "chatTeam" :
                ChatSettings := ((A_GuiControl = "chatAll") ? True : False)
                GuiInGame("Edit", "Overlay", {"id" : "chatAll" , "Color" : ( ChatSettings ? "Lime" : "Red")})
                GuiInGame("Edit", "Overlay", {"id" : "chatTeam", "Color" : (!ChatSettings ? "Lime" : "Red")})
                GuiInGame("Edit", "LauncherGUI", {"id" : "chatAll" , "Color" : ( ChatSettings ? "Lime" : "Red")})
                GuiInGame("Edit", "LauncherGUI", {"id" : "chatTeam", "Color" : (!ChatSettings ? "Lime" : "Red")})
            case "CB_ShowOverlay" :
                StringReplace, aVar, %A_GuiControl%, ""
                if aVar
                    Overlay("MiniOverlayShow")
                Else Overlay("MiniOverlayDestroy")
            case "HK_GUI" :
                StringReplace, localHK, %A_GuiControl%, ""
                if localHK {
                    Hotkey, *%StartKey%, Main, Off
                    StartKey := localHK
                    Hotkey, *%StartKey%, Main
                }
            case "KeyExport" :
                local ExportFolder 
                FileSelectFolder, ExportFolder, "*" LastFolder, 0, Вберите папку для сохранения файла настроек. `nSelect a folder to save the settings file.
                if !ErrorLevel {
                    LastFolder := ExportFolder
                    FileAppend, , % ExportFolder . "\Lol Chat (Backup settings).ini"
                    Loop, 20 {
                        aVar := gTitle%A_Index%
                        IniWrite, %aVar%, % ExportFolder . "\Lol Chat (Backup settings).ini", Titles , gTitle%A_Index%
                        aVar := gText%A_Index%
                        IniWrite, %aVar%, % ExportFolder . "\Lol Chat (Backup settings).ini", Texts , gText%A_Index%
                    }
                }
            case "KeyImport" :
                local ImportFolder
                FileSelectFile, ImportFolder, 3,, Вберите файл с настройками | Select the settings file, *.ini
                if !ErrorLevel && RegExMatch(ImportFolder, "i)\.ini$") {
                    LoadIniSection(ImportFolder, "All")
                    GuiInGame("Edit", "LauncherGUI", {"id" : "EditTitle", "Text" : (gTitle%SelectedSlot% ? gTitle%SelectedSlot% : " ")})
                    GuiInGame("Edit", "LauncherGUI", {"id" : "EditText" , "Text" : (gText%SelectedSlot% ? gText%SelectedSlot% : " ")})
                }
        }
    }

    Launcher() {
        global
        UpdateDGP({"FontSize" : 12, "Font" : "Sylfaen"})
        local PlaceForTheText := "123"
        local LauncherDGP   := UpdateDGP("Save")
        local LauncherText  := "ff7d19"
        local LauncherText2 := "E6F1FF"
        local LauncherText3 := "19e1ff"
        local LauncherBG    := "1e1e1e"
        local LauncherBG2   := "0f0f0f"
        ;--------------------------------------------------
        Gui, LauncherGUI: New, +LastFound -DPIScale +Border -MinimizeBox +HwndLauncherGUI +LabelLauncherGUI
        Gui, LauncherGUI: Color, %LauncherBG%, %LauncherBG2%
        Gui, LauncherGUI: Margin, % LauncherDGP.Margin.1, % LauncherDGP.Margin.2
        Gui, LauncherGUI: Font, % " s"LauncherDGP.FontSize " q3", % LauncherDGP.Font
        Gui, LauncherGUI: Show, % " w"(A_ScreenWidth/2) " h"(A_ScreenWidth/2/16*9), League of Legends - Chat Helper
        ;--------------------------------------------------
        local LauncherW := fGuiSize(LauncherGUI).w
        Loop, 20 {
            Gui, LauncherGUI: Add, Text, % " xm y+m +Center +Border c" (A_Index = SelectedSlot ? "Lime" : "Red")" +BackgroundTrans gGUI_Handler vKey" A_Index " +HwndKey" A_Index, %PlaceForTheText%
            GuiControl, LauncherGUI: Text, Key%A_Index%, %A_Index%
        }
        local LauncherH := fGuiSize(Key1).h
        ;--------------------------------------------------
        Gui, LauncherGUI: Add, Text, % " x+m ym w" (LauncherW/2.5) " h" LauncherH " +Center c" LauncherText " +BackgroundTrans gGUI_Handler +HwndEditTitle", Message title
        Gui, LauncherGUI: Add, Edit, % " xp y+m w" (LauncherW/2.5) " h" fGuiSize(Key2, Key4).h " +Center c" LauncherText2 " gGUI_Handler vEditTitle -VScroll", % gTitle%SelectedSlot%
        ;--------------------------------------------------
        Gui, LauncherGUI: Add, Text, % " xp y+m w" (LauncherW/2.5) " h" LauncherH " +Center c" LauncherText " +BackgroundTrans gGUI_Handler", Message text
        Gui, LauncherGUI: Add, Edit, % " xp y+m w" (LauncherW/2.5) " h" fGuiSize(Key6, Key18).h " c" LauncherText2 " gGUI_Handler vEditText -VScroll +Section", % gText%SelectedSlot%
        ;--------------------------------------------------
        Gui, LauncherGUI: Add, Text, % " xp y+m w" fGuiSize(EditTitle).w/2 - LauncherDGP.Margin.1 " +Center +Border cFuchsia +BackgroundTrans gGUI_Handler vKeyCancel", Cancel
        Gui, LauncherGUI: Add, Text, % " x+m yp w" fGuiSize(EditTitle).w/2 " +Center +Border cFuchsia +BackgroundTrans gGUI_Handler vKeySave", Save
        Gui, LauncherGUI: Add, Text, % " xs y+m w" fGuiSize(EditTitle).w/2 - LauncherDGP.Margin.1 " +Center +Border c" LauncherText3 " +BackgroundTrans gGUI_Handler vKeyImport", Import messages
        Gui, LauncherGUI: Add, Text, % " x+m yp w" fGuiSize(EditTitle).w/2 " +Center +Border c" LauncherText3 " +BackgroundTrans gGUI_Handler vKeyExport", Export messages
        ;--------------------------------------------------
        Gui, LauncherGUI: Add, GroupBox, % " x+m ym w" (LauncherW/5) " r1.5 +Center +Section c" LauncherText3 " HwndGB1" ,` Message settings ` 
        LauncherGB := ((fGuiSize(GB1).w/2) - (LauncherDGP.Margin.1 * 3))
        Gui, LauncherGUI: Add, Text, % " xp yp w1 +BackgroundTrans "
        Gui, LauncherGUI: Add, Text, % " x+m y+m w" LauncherGB " +c" ( ChatSettings ? "Lime" : "Red") " +Center +BackgroundTrans +Border gGUI_Handler vchatAll",`   ALL   `
        Gui, LauncherGUI: Add, Text, % " x+m yp w" LauncherGB " +c" (!ChatSettings ? "Lime" : "Red") " +Center +BackgroundTrans +Border gGUI_Handler vchatTeam",`   TEAM   `
        ;--------------------------------------------------
        Gui, LauncherGUI: Add, Text, % " xs y+s w1 +BackgroundTrans "
        Gui, LauncherGUI: Add, Text, % " xs y+s"
        Gui, LauncherGUI: Add, Checkbox, % " x+ Checked" CB_ShowOverlay " vCB_ShowOverlay gGUI_Handler" 
        Gui, LauncherGUI: Add, Text, % " x+ w" LauncherGB*1.9 " +Left c" LauncherText3, Show overlay
        ;--------------------------------------------------
        ; Gui, LauncherGUI: Add, Text, % " xs y+m w" LauncherGB*1.5 " h" LauncherH " +Right c" LauncherText3 " +BackgroundTran", StartKey: `
        ; Gui, LauncherGUI: Add, Hotkey, % " x+ yp w" LauncherGB " h" LauncherH " gGUI_Handler vHK_GUI", %gStartKey%
        ;--------------------------------------------------
        ; Gui, LauncherGUI: Font, % " s"LauncherDGP.FontSize * 5
        ; Gui, LauncherGUI: Add, Text, % " x+m ym w" (LauncherW/5) " h" fGuiSize(Key1, Key4).h " +Center +Border +BackgroundTrans cLime gGUI_Handler vKeyStart", Start
        ; Gui, LauncherGUI: Font, % " s"LauncherDGP.FontSize * 1.25
        ; Gui, LauncherGUI: Add, Text, % " xp ys w" (LauncherW/5) " +Center +Border c" LauncherText " gGUI_Handler vMessageCount",` Message Count:
        ;--------------------------------------------------
        Gui, LauncherGUI: Add, Picture, % " x" LauncherW*0.875 " ym w"LauncherW/10 " h-1 +Border vDiscordGUI", % "HBITMAP:" ReadImages(CheckingFiles("File", False, "Base_Images.dll"), "Discord1")
        funcObj := Func("Tray_links").Bind("Discord")
        GuiControl LauncherGUI: +g, DiscordGUI, %funcObj%
        ;--------------------------------------------------
        Gui, LauncherGUI: Add, Picture, % "xp y+m wp h-1 +Border vGitHubGUI", % "HBITMAP:" ReadImages(CheckingFiles("File", False, "Base_Images.dll"), "GitHub1")
        funcObj := Func("Tray_links").Bind("GitHub")
        GuiControl LauncherGUI: +g, GitHubGUI, %funcObj%
        ;--------------------------------------------------
        Gui, LauncherGUI: Add, Picture, % "x0 y0 w" (A_ScreenWidth/2) " h-1", % "HBITMAP:" ReadImages(CheckingFiles("File", False, "LeagueOfLegends_Images.dll"), "LoL_BG2")
    }

    Overlay(param) {
        global
        switch param {
            case "Start" :
                UpdateDGP("Default")
                UpdateDGP({"Scale" : gInterfaceScale})
                static OverlayImageBG := CreateImage(CheckingFiles("File", False, "LeagueOfLegends_Images.dll"), "LoL_BG")
                GuiInGame("Start", "Overlay")
                    Gui, Overlay: -E0x20
                    Gui, Overlay: Add, Picture, % "x0 y0 w" (A_ScreenWidth/2) " h-1", %OverlayImageBG%
                    loop, 20 {
                        if A_Index = 1
                            Gui, Overlay: Add, Text, % " xm ym w" (A_ScreenWidth/4) " h"(A_ScreenWidth/20/16*9) " +c"gColor " +Center +Border +BackgroundTrans gGUI_Handler vKey" A_Index,
                        Else if A_Index = 11
                            Gui, Overlay: Add, Text, % " x+m ym w" (A_ScreenWidth/4) " h"(A_ScreenWidth/20/16*9) " +c"gColor " +Center +Border +BackgroundTrans gGUI_Handler vKey" A_Index,
                        Else
                            Gui, Overlay: Add, Text, % " xp y+m w" (A_ScreenWidth/4) " h"(A_ScreenWidth/20/16*9) " +c"gColor " +Center +Border +BackgroundTrans gGUI_Handler vKey" A_Index,
                        GuiControl, Overlay: Text, Key%A_Index%, % gTitle%A_Index%
                    }
                    Gui, Overlay: Add, Text, % " xm y+m +c19e1ff +Center +BackgroundTrans", Message settings :
                    Gui, Overlay: Add, Text, % " x+m yp +c" ( ChatSettings ? "Lime" : "Red") " +Center +BackgroundTrans +Border gGUI_Handler vchatAll",`   ALL   `
                    Gui, Overlay: Add, Text, % " x+m yp +c" (!ChatSettings ? "Lime" : "Red") " +Center +BackgroundTrans +Border gGUI_Handler vchatTeam",`   TEAM   `
                GuiInGame("End", "Overlay")
                WinSet, TransColor, Off, % "ahk_id" Overlay
                GuiInGame("Hide", "Overlay")
            case "Hide" : GuiInGame("Hide", "Overlay")
            case "Show" : GuiInGame("Show", "Overlay")
            case "Update" : GuiInGame("Destroy", "Overlay"), Overlay("Start")
            case "MiniOverlayShow" :
                UpdateDGP("Default")
                UpdateDGP({"Transparency" : gTransparency, "Blur" : gBlur, "Scale" : gInterfaceScale})
                GuiInGame("Start", "MiniOver")
                    Gui, MiniOver: Add, Text, % "xm ym +Center c"gColor , % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1) " is running"
                GuiInGame("End", "MiniOver", {"ratio" : [GuiPositionX,GuiPositionY]})
            case "MiniOverlayDestroy" : GuiInGame("Destroy", "MiniOver")
        }
    }

;;;;;;;;;; Scripts ;;;;;;;;;;
    Main() {
        global
        ChoiceWaiting := True
        Overlay("Show")
        While (GetKeyState(StartKey, "p") && ChoiceWaiting)
            lSleep(100)
        Overlay("Hide")
        While GetKeyState(StartKey, "p")
            lSleep(100)
    }

    fSplitText(Text, MaxLength = 125) {
        /*
            Разбивает длинный текст на несколько частей, стараясь сохранить
            естественные места разрыва. 

            Параметры:
                Text      - Текст, который необходимо разбить.
                MaxLength - Максимальное количество символов в одной части. 

            Возвращает:
                Объект-массив с частями текста.
                Если текст не превышает MaxLength, возвращается массив
                с одним элементом.  

            При разбиении используются следующие приоритеты:
                1. Конец предложения: . ! ?
                2. Другие знаки препинания: , ; :
                3. Последний пробел перед ограничением. 

            Знаки препинания учитываются только в последней четверти
            допустимой длины сообщения, чтобы не создавать слишком короткие части.  

            Если отдельное слово само по себе длиннее MaxLength,
            оно будет принудительно разделено.  

            Пример:
                Parts := fSplitText("Очень длинный текст...", 125)  

                for Index, Text in Parts {
                    MsgBox, %Text%
                }
        */
        Parts := []
        Text := Trim(Text)
        while (StrLen(Text) > MaxLength) {
            Part := SubStr(Text, 1, MaxLength)
            SplitPos := 0
            ; Ищем конец предложения в последней четверти сообщения.
            StartPos := Ceil(MaxLength * 0.75)
            Loop, % MaxLength - StartPos + 1 {
                Pos := MaxLength - A_Index + 1
                Char := SubStr(Part, Pos, 1)

                if (Char = "." || Char = "!" || Char = "?") {
                    SplitPos := Pos
                    break
                }
            }
            ; Если конец предложения не найден,
            ; ищем запятую, точку с запятой или двоеточие.
            if (!SplitPos) {
                Loop, % MaxLength - StartPos + 1 {
                    Pos := MaxLength - A_Index + 1
                    Char := SubStr(Part, Pos, 1)

                    if (Char = "," || Char = ";" || Char = ":") {
                        SplitPos := Pos
                        break
                    }
                }
            }
            ; Если подходящего знака препинания нет,
            ; ищем последний пробел.
            if (!SplitPos) {
                Loop, %MaxLength% {
                    Pos := MaxLength - A_Index + 1

                    if (SubStr(Part, Pos, 1) = " ") {
                        SplitPos := Pos
                        break
                    }
                }
            }
            ; Если пробела тоже нет, значит первое слово
            ; длиннее MaxLength. В этом случае приходится
            ; принудительно разделить слово.
            if (!SplitPos)
                SplitPos := MaxLength
            Part := RTrim(SubStr(Text, 1, SplitPos), " `t`r`n")
            Text := LTrim(SubStr(Text, SplitPos + 1), " `t`r`n")
            Parts.Push(Part)
        }
        ; Добавляем оставшуюся часть текста.
        if (Text != "")
            Parts.Push(Text)
        return Parts
    }

;;;;;;;;;; Exit ;;;;;;;;;;
    LauncherGUIClose() {
        ExitApp
    }

    BeforeExiting() {
        global 
        local аValue
        Loop, 20 {
            аValue := gTitle%A_Index%
            IniWrite, %аValue%, %OP_LolChat%, Titles , gTitle%A_Index%
            аValue := gText%A_Index%
            IniWrite, %аValue%, %OP_LolChat%, Texts , gText%A_Index%
        }
        ;--------------------------------------------------
        IniWrite, %StartKey%, %OP_SavedSettings%, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1), StartKey
        IniWrite, %ChatSettings%, %OP_SavedSettings%, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1), ChatSettings
        IniWrite, %CB_ShowOverlay%, %OP_SavedSettings%, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1), CB_ShowOverlay
        IniWrite, %SelectedSlot%, %OP_SavedSettings%, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1), SelectedSlot
        IniWrite, %LastFolder%, %OP_SavedSettings%, % SubStr(A_ScriptName, 1, InStr(A_ScriptName, ".", , -1) - 1), LastFolder
        FileDelete, %OverlayImageBG%
    }