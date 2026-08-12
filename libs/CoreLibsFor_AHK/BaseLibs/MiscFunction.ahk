    fWinGetClientPos(winTitle) {
        /*
            Возвращает положение и размер клиентской области окна.

            winTitle - Заголовок окна или любой другой параметр WinTitle.

            Возвращает объект:
                x - Координата X клиентской области.
                y - Координата Y клиентской области.
                w - Ширина клиентской области.
                h - Высота клиентской области.

            Пример:
                Pos := fWinGetClientPos("A")
                MsgBox % Pos.x ", " Pos.y ", " Pos.w ", " Pos.h
        */
        if !hWnd := WinExist(Trim(winTitle))  {
           MsgBox, 262160, fWinGetClientPos, Окно %winTitle% не найдено.`nThe %winTitle% window was not found.
           Return, 0
        }
        VarSetCapacity(WINDOWINFO, 60, 0)
        NumPut(60, WINDOWINFO, 0, "UInt")
        if !DllCall("GetWindowInfo", Ptr, hWnd, Ptr, &WINDOWINFO)
            Return, 0
        Return { "x" : x := NumGet(WINDOWINFO, 20, "UInt")
               , "y" : y := NumGet(WINDOWINFO, 24, "UInt")
               , "w" : NumGet(WINDOWINFO, 28, "UInt") - x
               , "h" : NumGet(WINDOWINFO, 32, "UInt") - y }
    }