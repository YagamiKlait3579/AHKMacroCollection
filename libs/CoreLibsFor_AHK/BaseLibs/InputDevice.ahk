; global PWN := "" ; Program window name

;;;;;;;;;; Mouse ;;;;;;;;;;
    fSetCursor(x, y) {
        /* 
            fSetCursor мгновенно перемещает курсор мыши в указанную точку экрана. 
            Координаты указываются в абсолютных экранных координатах. 

            x = Координата по оси X. 
            y = Координата по оси Y. 
        */
        Dllcall("SetCursorPos" , "Int", x, "Int", y)
    }

    fGetCursor() {
        /* 
            fGetCursor возвращает текущую позицию курсора мыши на экране. 
            Результат возвращается в виде объекта: Position.x Position.y 
            Пример: 
                Position := fGetCursor() 
                MsgBox % Position.x " | " Position.y 
        */
		VarSetCapacity(POINT, 8, 0)
		DllCall("GetCursorPos", "Uint", &POINT)
		Return {x : NumGet(POINT, 0, "Int"), y : NumGet(POINT, 4, "Int")}
	}

    fMoveMouse(x, y) {
        /*
            fMoveMouse эмулирует движение мыши через Windows API mouse_event.

            Перед выполнением движения курсор автоматически перемещается в центр экрана.
            Это позволяет избежать ситуаций, когда курсор упирается в границу экрана или
            переходит на другой монитор при использовании нескольких дисплеев.

            Функция особенно полезна в играх, где движение мыши и позиция курсора являются
            разными понятиями, а также при работе с играми, использующими относительный ввод.

            x = Смещение по оси X.
            y = Смещение по оси Y.

            Для максимальной надежности рекомендуется не использовать значения, превышающие
            половину ширины или высоты экрана за один вызов функции.
        */
        Dllcall("SetCursorPos" , "Int", A_ScreenWidth/2, "Int", A_ScreenHeight/2)
        DllCall("mouse_event", "UInt", 0x01, "Int", x, "Int", -y, "UInt", 0, "Int", 0)
    }

    fMouseInput(Key = "Left", status = 25) {
        /*
            Функция создаёт действия мыши с помощью Windows API mouse_event.

            Key = Тип действия: 
            "Left", "Right", "Mid" 
            "WheelUp", "WheelDown" 
            "WheelLeft", "WheelRight" 
            "XBUTTON1", "XBUTTON2"

            status = Режим действия.
                Для кнопок мыши:
                    Число (ms) - выполнить нажатие и удерживать кнопку указанное количество миллисекунд. 
                    "Down" - нажать кнопку без отпускания. 
                    "Up" - отпустить кнопку.
                Для колеса мыши:
                    Число - количество шагов прокрутки.
        */
        switch (Key) {
            case "Left":  (status = "Down" ? DllCall("mouse_event", "UInt", 0x02)  : (status = "Up" ? DllCall("mouse_event", "UInt", 0x04)  : (DllCall("mouse_event", "UInt", 0x02),  lSleep(status), DllCall("mouse_event", "UInt", 0x04))))
            case "Right": (status = "Down" ? DllCall("mouse_event", "UInt", 0x08)  : (status = "Up" ? DllCall("mouse_event", "UInt", 0x10)  : (DllCall("mouse_event", "UInt", 0x08),  lSleep(status), DllCall("mouse_event", "UInt", 0x10))))
            case "Mid":   (status = "Down" ? DllCall("mouse_event", "UInt", 0x020) : (status = "Up" ? DllCall("mouse_event", "UInt", 0x040) : (DllCall("mouse_event", "UInt", 0x020), lSleep(status), DllCall("mouse_event", "UInt", 0x040))))
            case "WheelUp", "WheelDown":
                Loop, %status%
                    (DllCall("mouse_event", "UInt", 0x0800, "Int", 0, "Int", 0, "UInt", (Key = "WheelUp" ? 120 : -120), "Int", 0))
            case "WheelRight", "WheelLeft": 
                loop, %status%
                    (DllCall("mouse_event", "UInt", 0x01000, "Int", 0, "Int", 0, "UInt", (Key = "WheelRight" ? 120 : -120), "Int", 0))
            case "XBUTTON1": (status = "Down" ?  (DllCall("mouse_event", "UInt", 0x0080, "Int", 0, "Int", 0, "UInt", 0x0001, "Int", 0)) : (status = "Up" ? (DllCall("mouse_event", "UInt", 0x0100, "Int", 0, "Int", 0, "UInt", 0x0001, "Int", 0)) : (DllCall("mouse_event", "UInt", 0x0080, "Int", 0, "Int", 0, "UInt", 0x0001, "Int", 0),  lSleep(status), DllCall("mouse_event", "UInt", 0x0100, "Int", 0, "Int", 0, "UInt", 0x0001, "Int", 0))))
            case "XBUTTON2": (status = "Down" ?  (DllCall("mouse_event", "UInt", 0x0080, "Int", 0, "Int", 0, "UInt", 0x0002, "Int", 0)) : (status = "Up" ? (DllCall("mouse_event", "UInt", 0x0100, "Int", 0, "Int", 0, "UInt", 0x0002, "Int", 0)) : (DllCall("mouse_event", "UInt", 0x0080, "Int", 0, "Int", 0, "UInt", 0x0002, "Int", 0),  lSleep(status), DllCall("mouse_event", "UInt", 0x0100, "Int", 0, "Int", 0, "UInt", 0x0002, "Int", 0))))
        }
    }

    fMouseClick(x, y, ClickCount = 1, Delay = 25, MoveAfter = "", Button = "Left") {
        /*
            Выполняет клик мышью по указанным экранным координатам.
            Перед кликом перемещает курсор в указанную позицию и ожидает заданное время,
            чтобы приложение или игра успела отреагировать на перемещение мыши.

            x, y        - Экранные координаты позиции клика.
            ClickCount  - Количество кликов. (1 по умолчанию)
            Delay       - Задержка в миллисекундах после перемещения курсора и между кликами. (25 ms. по умолчанию)
            MoveAfter   - Перемещение курсора после выполнения:
                          "Center"      - в центр экрана.
                          "TopLeft"     - в левый верхний угол.
                          "TopRight"    - в правый верхний угол.
                          "BottomLeft"  - в левый нижний угол.
                          "BottomRight" - в правый нижний угол.
                          ""            - не перемещать курсор. (По умолчанию)
            Button      - Кнопка мыши: "Left" (По умолчанию), "Right" или "Middle".

            Пример:
            fMouseClick(500, 500)                  ; Одиночный клик ЛКМ.
            fMouseClick(500, 500, 2)               ; Двойной клик ЛКМ.
            fMouseClick(500, 500, 1, 25,, "Right") ; Клик ПКМ.
            fMouseClick(500, 500, 3, 50, "Center") ; 3 клика и убрать курсор в центр.
        */
        fSetCursor(x, y)
        lSleep(Delay)
        Loop, %ClickCount% {
            fMouseInput(Button)
            if (A_Index < ClickCount)
                lSleep(Delay)
        }
        Switch MoveAfter {
            case "Center"      : fSetCursor(A_ScreenWidth / 2, A_ScreenHeight / 2)
            case "TopLeft"     : fSetCursor(1, 1)
            case "TopRight"    : fSetCursor(A_ScreenWidth, 1)
            case "BottomLeft"  : fSetCursor(1, A_ScreenHeight)
            case "BottomRight" : fSetCursor(A_ScreenWidth, A_ScreenHeight)
        }            
    }

    fMouseInputToWin(WinTitle, Key := "Left", x := 0, y := 0, WheelRotation = 1) {
        /* 
            Функция эмулирует события мыши в указанном окне. 

            WinTitle - Заголовок или идентификатор целевого окна. 
            Подробнее тут: https://www.autohotkey.com/docs/v1/lib/WinActivate.htm

            Key - Тип действия (по умолчанию "Left").
                Кнопки: "Left", "Right", "Middle", "XButton1", "XButton2"
                Колесо: "WheelUp", "WheelDown", "WheelLeft", "WheelRight"
            x, y - Координаты внутри окна (не экрана!) для позиционирования.
                (0,0) - верхний левый угол клиентской области окна

            WheelRotation  - Количество "оборотов" прокрутки (по умолчанию 1)
        */
        static KeyList := { Left:     {Down: 0x0201, Up: 0x0202}    ; WM_LBUTTONDOWN, WM_LBUTTONUP
                          , Right:    {Down: 0x0204, Up: 0x0205}    ; WM_RBUTTONDOWN, WM_RBUTTONUP
                          , Middle:   {Down: 0x0207, Up: 0x0208}    ; WM_MBUTTONDOWN, WM_MBUTTONUP
                          , XButton1: {Down: 0x020B, Up: 0x020C} 
                          , XButton2: {Down: 0x020B, Up: 0x020C} 
                          , WheelUp:    0x020A, WheelDown: 0x020A   ; WM_MOUSEWHEEL
                          , WheelRight: 0x020E, WheelLeft: 0x020E } ; WM_MOUSEHWHEEL
        hWnd := WinExist(WinTitle)
        if !hWnd {
            MsgBox, 262160, fKbInputToWin, Окно с именем %WinTitle% не найдено.`nThe window named %WinTitle% was not found.
            return
        }
        lParam := (y << 16) | (x & 0xFFFF)
        switch (Key) {
            case "WheelUp", "WheelDown", "WheelRight", "WheelLeft": {
                Loop % WheelRotation {
                    wParam := ((Key = "WheelUp" || Key = "WheelRight") ? 120 : -120) << 16
                    PostMessage, % KeyList[Key], %wParam%, %lParam%, , ahk_id %hWnd%
                }
            }
            Default : {
                if (Key = "XButton1" || Key = "XButton2")
                    wParam := (Key = "XButton1" ? 0x0001 : 0x0002) << 16
                PostMessage, % KeyList[Key].Down, % wParam, % lParam, , ahk_id %hWnd%
                PostMessage, % KeyList[Key].Up, % wParam, % lParam, , ahk_id %hWnd%
            }
        }
    }

;;;;;;;;;; Keyboard ;;;;;;;;;;
    fKbInput(Key, status = "Press") {
        /*
            Kb = Keyboard
            Функция создаёт действия клавиатуры с помощью Windows API keybd_event.

            Параметр Key можно указать одним из способов (примеры для клавиши "Пробел").
                По имени, например fKeyboardInput("Space").
                Через Virtual Key (VK), например fKeyboardInput("vk0x20").
                Через Scan Code , например fKeyboardInput("sc0x39").

            Параметр status:
                "Press" — нажатие и отпускание (по умолчанию).
                "Down" — зажатие клавиши (без отпускания).
                "Up" — отпускание клавиши.
        */
        ScanCode := Format("0x{:X}", GetKeySC(Key))
        if !ScanCode {
            MsgBox, 262160, fKeyboardInput, Клавиша %Key% не найдена или указана неверно.`nThe %Key% key was not found or specified incorrectly.
            Return
        }
        if (status = "Down" || status = "Press")
            DllCall("keybd_event", "UChar",  0, "UChar", ScanCode, "UInt", 8, "Ptr", 0)
        if (status = "Up" || status = "Press")
            DllCall("keybd_event", "UChar",  0, "UChar", ScanCode, "UInt", 2, "Ptr", 0)
    }

    fSendIfWinActive(Key_Code, Key_status = "", NameWindow = "") {
        /*
            Функция отправляет нажатие клавиши только в том случае,
            если указанное окно в данный момент активно.

            Функция использует текущий режим отправки, установленный
            командой SendMode. Поэтому поведение отправки соответствует
            обычной команде Send в текущем скрипте.

            Параметр Key_Code:
                Код или название клавиши, передаваемое команде Send.

            Параметр Key_status:
                Дополнительный параметр состояния клавиши.
                Например: "Down" или "Up".

            Параметр NameWindow:
                Заголовок или идентификатор окна.
                Если не указан, используется глобальная переменная PWN.

            Возвращаемое значение:
                1 — нажатие отправлено.
                0 — указанное окно не активно.

            Пример:
                fSendIfWinActive("F1")
                fSendIfWinActive("Space", "Down")
                fSendIfWinActive("Space", "Up")
                fSendIfWinActive("Enter", "Up", "ahk_exe Game.exe")
        */
        if (!NameWindow && !PWN) {
            MsgBox, 262160, fSendIfWinActive, Window name error
            Return
        }
        NameWindow := NameWindow != "" ? NameWindow : PWN
        if WinActive(NameWindow) {
            Send, {Blind}{%Key_Code% %Key_status%}
            Return 1
        }
        Return 0
    }

    fKbInputToWin(WinTitle, Key, State := "Press", SwitchToWin := 0) {
        /* 
            Функция отправляет эмуляцию нажатий клавиатуры в указанное окно.
            ВНИМАНИЕ: Имеет серьёзные ограничения из-за особенностей Windows (см. P.S.)

            WinTitle - Заголовок или идентификатор целевого окна. 
            Подробнее тут: https://www.autohotkey.com/docs/v1/lib/WinActivate.htm

            Параметр Key можно указать одним из способов (примеры для клавиши "Пробел").
                По имени, например fKeyboardInput("Space").
                Через Virtual Key (VK), например fKeyboardInput("vk0x20").
                Через Scan Code , например fKeyboardInput("sc0x39").

            Параметр status:
                "Press" — нажатие и отпускание (по умолчанию).
                "Down" — зажатие клавиши (без отпускания).
                "Up" — отпускание клавиши.

            Параметр SwitchToWin:
                Если указано (время в ms), активирует окно на это время перед эмуляцией нажатия,
                после нажатия возвращается обратно к активному окну.
                Если не указано (по умолчанию), пытается отправить нажатие без активации окна (работает не везде).

            P.S. Важные ограничения:
                1. В Windows отправка клавиш в фоновые окна без активации работает ТОЛЬКО
                   для некоторых приложений (обычно старых или консольных)
                2. Для большинства современных программ требуется активация окна (SwitchToWin > 0)
                3. Если окно активно, рекомендуется использовать стандартные методы AHK (Send или fKbInput)
                4. Функция использует PostMessage с WM_KEYDOWN/WM_KEYUP, что не всегда равноценно реальному вводу 
                5. Использование State="Down"/"Up" чаще всего бессмысленно, так как:
                    - При PostMessage невозможно корректно эмулировать ЗАЖАТИЕ клавиши
                    - Большинство программ обрабатывают только полный цикл нажатия (Press)
                    - Может нарушаться синхронизация состояний клавиатуры
        */
        hWnd := WinExist(WinTitle)
        if !hWnd {
            MsgBox, 262160, fKbInputToWin, Окно с именем %WinTitle% не найдено.`nThe window named %WinTitle% was not found.
            return
        }
        if SwitchToWin {
            activeWindow := WinExist("A")
            WinActivate, ahk_id %hWnd%
            WinWaitActive, ahk_id %hWnd%, , 0.5
            if ErrorLevel {
                MsgBox, 262160, fKbInputToWin, Не удалось переключиться на окно %WinTitle%.`nCouldn't switch to %WinTitle% window. `n`nhWnd: %hWnd%
                Return
            }
            lSleep(SwitchToWin)
        }
        ScanCode   := Format("0x{:X}", GetKeySC(Key))
        VirtualKey := Format("0x{:X}", GetKeyVK(Key))
        ;isTextKey := (VirtualKey >= 0x30 && VirtualKey <= 0x5A) || VirtualKey == 0x20  ; 0-9, A-Z, Space
        if (State = "Down" || State = "Press") {
            PostMessage, 0x100, % VirtualKey, (ScanCode << 16) | 0x00000001, , ahk_id %hWnd%  ; WM_KEYDOWN
            /* 
            if (isTextKey) {
                PostMessage, 0x102, % VirtualKey, (ScanCode << 16) | 0x00000001, , ahk_id %hWnd%  ; WM_CHAR
            }
            */
        }
        if (State = "Up" || State = "Press")
            PostMessage, 0x101, % VirtualKey, (ScanCode << 16) | 0xC0000001, , ahk_id %hWnd%  ; WM_KEYUP
        if SwitchToWin {
            lSleep(SwitchToWin)
            WinActivate, ahk_id %activeWindow%
        }
    }