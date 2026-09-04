#Requires AutoHotkey v2.0
#SingleInstance Force

; QTTabBar Auto Config
; Automatically switches QTTabBar configuration when the Windows app theme changes.

lastTheme := ""

lightConfig := A_ScriptDir "\config\QTTabBarConfig Light.xml"
darkConfig  := A_ScriptDir "\config\QTTabBarConfig Dark.xml"

; Check immediately at startup, then every 5 seconds.
CheckTheme()
SetTimer(CheckTheme, 5000)

CheckTheme(*) {
    global lastTheme, lightConfig, darkConfig

    try {
        theme := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
    } catch {
        ShowTip("Could not read the Windows theme setting.", 3000)
        return
    }

    if (theme = lastTheme)
        return

    configFile := (theme = 1) ? lightConfig : darkConfig

    if !FileExist(configFile) {
        ShowTip("QTTabBar config file not found:`n" configFile, 4000)
        return
    }

    ; Only remember the new theme after a successful import.
    if LoadConfig(configFile)
        lastTheme := theme
}

LoadConfig(filePath) {
    explorerHwnd := WinExist("ahk_class CabinetWClass")
    if !explorerHwnd {
        ShowTip("Open a File Explorer window first.", 3000)
        return false
    }

    WinActivate("ahk_id " explorerHwnd)
    if !WinWaitActive("ahk_id " explorerHwnd, , 3) {
        ShowTip("Could not activate File Explorer.", 3000)
        return false
    }

    ; Open QTTabBar options.
    Send("!o")

    optionsHwnd := WaitForDifferentActiveWindow(explorerHwnd, 2500)
    if !optionsHwnd {
        ShowTip("QTTabBar options did not open.", 3500)
        return false
    }

    ; Find the exact Import button by its exposed control text.
    ; Do NOT fall back to a fixed Tab count: that could click the wrong button.
    if !ClickButtonByExactText(optionsHwnd, ["Import now...", "Import now…", "Import now"], 3000) {
        ShowTip("Could not find the 'Import now...' button.`nNo other button was clicked.", 5000)
        return false
    }

    ; Wait for the standard file-open dialog.
    if !WinWaitActive("ahk_class #32770", , 3) {
        ShowTip("QTTabBar import dialog was not detected.", 3500)
        return false
    }

    Sleep(100)
    SendText(filePath)
    Sleep(100)
    Send("{Enter}")

    ShowTip("QTTabBar configuration loaded.", 2000)
    return true
}

WaitForDifferentActiveWindow(originalHwnd, timeoutMs) {
    start := A_TickCount
    while (A_TickCount - start < timeoutMs) {
        activeHwnd := WinExist("A")
        if (activeHwnd && activeHwnd != originalHwnd)
            return activeHwnd
        Sleep(50)
    }
    return 0
}

ClickButtonByExactText(hwnd, acceptedTexts, timeoutMs) {
    start := A_TickCount

    while (A_TickCount - start < timeoutMs) {
        try controls := WinGetControls("ahk_id " hwnd)
        catch {
            Sleep(100)
            continue
        }

        for ctrl in controls {
            try text := Trim(ControlGetText(ctrl, "ahk_id " hwnd))
            catch
                continue

            if !text
                continue

            ; Ignore accelerator markers and normalize whitespace.
            normalized := StrReplace(text, "&")
            normalized := RegExReplace(normalized, "\s+", " ")
            normalized := Trim(normalized)

            for wanted in acceptedTexts {
                if (StrLower(normalized) = StrLower(wanted)) {
                    try {
                        ControlClick(ctrl, "ahk_id " hwnd)
                        return true
                    }
                }
            }
        }

        Sleep(100)
    }

    return false
}

ShowTip(message, durationMs := 2500) {
    ToolTip(message, 10, 10)
    SetTimer(() => ToolTip(), -durationMs)
}
