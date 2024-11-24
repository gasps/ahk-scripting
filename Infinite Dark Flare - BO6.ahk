#Persistent
#NoEnv
#SingleInstance Force  ; prevent opening same script
if (A_AhkVersion >= 1.1)
    {
        MsgBox,AHK Version: 1.1`nYou are running a compatible version: %A_AhkVersion%
    }
    else
    {
        MsgBox, You must be using AHK v1.1 or higher.`nYou are running %A_AhkVersion%
    }

SetWorkingDir %A_ScriptDir%

; keeping timers persistent
SetTimer, FlareLoopFunction, Off  ; Set a timer to run the loop every 10 milliseconds
SetTimer, LoopFunction, Off  ; Set a timer to run the loop every 10 milliseconds
SetTimer, WatchCursor, 100  ; Timer to run every 100ms, making it smoother

; gui/toggle variables
toggle := false  ; script state = false
counter := 0     ; action loop counter
runningTime := 0 ; Running time initialized to 0
startTime := 0   ; tract start time

; script variables
soloToggle := false
spinToggle := false
spinIsEnabled := false
ranFirstSpinLoop := false ; spin loop

; Default GUI position
guiX := 100
guiY := 100

; dev shit
Duration := 2000  ; Default spin duration in milliseconds
LoopCount := 0  ; Counter to track loop iterations

; get script filename for title
ahkTitle := RegExReplace(A_ScriptName, "\.ahk$", "")

; predefined values
DarkFlareXY := "230, 381"
StringSplit, DarkFlare, DarkFlareXY, `,
FieldUpgradeXY := "1418, 417"
StringSplit, FieldUpgrade, FieldUpgradeXY, `,
FieldUpgradeKey := "X"
    ; solo value
    SOLOFieldUpgradeXY := "1505, 517"
    StringSplit, SOLOFieldUpgrade, SOLOFieldUpgradeXY, `,

; cooldown variables
lastFlareTime := 0  ; Time when the flare action was last executed
cooldownTime := 3000  ; Cooldown time in milliseconds (3 seconds)

; GUI Setup
Gui, +AlwaysOnTop +ToolWindow +Resize
Gui, Font, s8, Segoe UI
Gui, Add, Text, x10 y5 w330, Toggle Key: F4
Gui, Add, Text, x10 y20 w330, Close Script: F5
Gui, Add, Text, vState x10 y35  w330, Script Status: OFF
Gui, Add, Text, vTime x10 y50 w300, Running Time: 00:00:00
Gui, Add, Text, vCounter x10 y65 w330, Counter: 0
Gui, Add, Text, vDarkFlareText x155 y83, Dark Flare XY
Gui, add, Edit, vDarkFlarePOS x105 y80 w45 h20 Limit10, %DarkFlareXY%
Gui, Add, Text, vFieldUpgradeLabel x155 y108, Field Upgrade XY
Gui, Add, Edit, vFieldUpgradePOS x105 y105 w45 h20 Limit10, %FieldUpgradeXY%
Gui, Add, Text, vFieldUpgradeLabel2 x155 y133, Field Upgrade Key
Gui, Add, Edit, vFieldUpgradeKey x105 y130 w45 h20 Limit10, %FieldUpgradeKey%

Gui, Add, Checkbox, vSoloMode gToggleSolo x10 y100 w80 h20, Solo: OFF

Gui, Add, Button, gToggleSpin x180 y15 w80 h20, Do 180/Spin ; Button to save keybinds
Gui, Add, Text, vSpinText x263 y18, OFF


Gui, Add, Button, gSetValues x180 y160 w80 h20, Set ; Button to save keybinds
Gui, Add, Button, gSaveSettingsToFile x180 y180 w40 h20, Save ; Button to save keybinds
Gui, Add, Button, gLoadSettingsFromFile x220 y180 w40 h20, Load ; Button to save keybinds

Gui, Add, Button, gtoggleMouseXYButton x10 y160 w100 h20, Show Mouse XY
Gui, Add, Text, vMousePosToggleLabel x112 y163, Disabled
Gui, Add, Text, vMouseLabel x10 y145, XY:
Gui, Add, Text, vMousePOS x30 y145 w60 h15, N/A

Gui, Add, Text, vMouseStop x10 y130 w90 h15, Press F6 to stop
GuiControl, Hide, MouseStop

Gui, Add, Button, gCloseScript x10 y180, Close
Gui, Show, x%guiX% y%guiY% w300 h210, %ahkTitle%


FlareLoopFunction:
if (toggle) {
    ; Only execute the function if the cooldown time has passed
    if (A_TickCount - lastFlareTime > cooldownTime) {
        counter++
        GuiControl,, Counter, Counter: %counter%  ; Update the counter display

        ; Send the F1 key to trigger the necessary action
        Send, {F1}
        Sleep, 155

        ; Handle solo or group upgrade click based on the toggle
        if (!soloToggle) {
            MouseClick, Left, %FieldUpgrade1%, %FieldUpgrade2%
        } else {
            MouseClick, Left, %SOLOFieldUpgrade1%, %SOLOFieldUpgrade2%
        }
        Sleep, 155

        ; Click on the DarkFlare position
        MouseClick, Left, %DarkFlare1%, %DarkFlare2%
        Sleep, 155

        ; Send the escape key to close menus
        Send, {Esc}
        Sleep, 255

        ; Update lastFlareTime to the current time
        lastFlareTime := A_TickCount
        
        ; Send the field upgrade key to trigger upgrade action
        Sleep, 155
        Send, {%FieldUpgradeKey%}
        Sleep, 1000
        if (spinIsEnabled) {
        SetTimer, LoopFunction, 10
    }
    }
}
return

;;;;;;;;;;;;;;;;;;;;;;;
;;;; spin function ;;;;
;;;;;;;;;;;;;;;;;;;;;;;

; Loop function
LoopFunction:
if (toggle) {
    if (spinToggle) {

        counter++
        GuiControl,, Counter, Counter: %counter%  ; Update the counter display
        firstSpin := true
    
        if (firstSpin := true)  { 
        spin(-30, 1, Duration)
        Sleep, 150
        } else {
            spin(-28, 1, Duration)
            Sleep, 150
            firstSpin :=
        }

        If (LoopCount = 4) {
            spin(4, 1, Duration)
            LoopCount := 0
            Sleep, 150
        }
    }
}
return


spin(amount, speed, durationMS) {
    startTime := A_TickCount  ; Capture the start time of the spin
    end := startTime + durationMS  ; Set the end time based on the duration
    While (A_TickCount < end) {
        MouseMove, amount, 0, speed, R
    }
}




; start script with f4
F4::
    toggle := !toggle
    if (toggle) {    
        GuiControl,, State, Script Status: ON ; update script text to ON
        startTime := A_TickCount ; start timer
        ; remaining functions called
        SetTimer, FlareLoopFunction, 2000 ; Set a timer to run the loop every 10 milliseconds
        SetTimer, UpdateTime, 1000  ; update timer every second
    } else {
        GuiControl,, State, Script Status: OFF ; update script text to OFF
        ; stop remaining functions
        SetTimer, UpdateTime, Off  ; Stop updating time
        counter := 0  ; reset loop counter to 0
        GuiControl,, Counter, Counter: 0  ; reset the loop counter display
        ;Send, {RButton up}{e up}{2 up}{x up}{g up}  ; release any keys pressed
    }
    return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; save and load functions | set values function ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SaveSettingsToFile:
if (FileExist("settings.txt")) { ; delete save file to stop overflow
    FileDelete, settings.txt
}
Gui, Submit, NoHide ; update values in gui

    DarkFlareXY := DarkFlarePOS
    if (soloToggle) {
        SOLOFieldUpgradeXY := SOLOFieldUpgradePOS
        StringSplit, SOLOFieldUpgrade, SOLOFieldUpgradeXY, `,
    } else {
        FieldUpgradeXY := FieldUpgradePOS
        StringSplit, FieldUpgrade, FieldUpgradeXY, `,
    }

    FieldUpgradeKey := FieldUpgradeKey

    FileAppend, DarkFlareXY=%DarkFlareXY%`n, settings.txt
    FileAppend, FieldUpgradeXY=%FieldUpgradeXY%`n, settings.txt
    FileAppend, SOLOFieldUpgradeXY=%FieldUpgradeXY%`n, settings.txt
    FileAppend, FieldUpgradeKey=%FieldUpgradeKey%`n, settings.txt
    workingDir := A_WorkingDir
    SendMessage("Save files successfully to settings.txt`n" . workingDir . "\settings.txt!")
    return
    

LoadSettingsFromFile:
    ; reads file, loops for every line, parses all strings, splits all values after "=", then sets gui values. automatically sets them after.
    FileRead, settings, settings.txt
    Loop, parse, settings, `n
    {
        if InStr(A_LoopField, "DarkFlareXY")
            StringSplit, DarkFlare, A_LoopField, =
            GuiControl,, DarkFlarePOS, %DarkFlare2%

        if (soloToggle) {
            if InStr(A_LoopField, "SOLOFieldUpgradeXY")
                StringSplit, SOLOFieldUpgrade, A_LoopField, =
                GuiControl,, SOLOFieldUpgradePOS, %SOLOFieldUpgrade2%
    
        } else {
            if InStr(A_LoopField, "FieldUpgradeXY")
                StringSplit, FieldUpgrade, A_LoopField, =
                GuiControl,, FieldUpgradePOS, %FieldUpgrade2%
        }
        if InStr(A_LoopField, "FieldUpgradeKey")
            StringSplit, FieldUpgradeKey, A_LoopField, =
            GuiControl,, FieldUpgradeKey, %FieldUpgradeKey2%

    }

    Gui, Submit, NoHide

    ; update values
    DarkFlareXY := DarkFlarePOS
    if (soloToggle) {
        SOLOFieldUpgradeXY := SOLOFieldUpgradePOS
        StringSplit, SOLOFieldUpgrade, SOLOFieldUpgradeXY, `,
    } else {
        FieldUpgradeXY := FieldUpgradePOS
        StringSplit, FieldUpgrade, FieldUpgradeXY, `,
    }

    FieldUpgradeKey := FieldUpgradeKey
    SendMessage("Loaded the values and set them successfully!")
return

SetValues:
    Gui, Submit, NoHide ; Save all input from the GUI controls into their associated variables
    ; Update variables with new values from the GUI
    DarkFlareXY := DarkFlarePOS
    if (soloToggle) {
        SOLOFieldUpgradeXY := SOLOFieldUpgradePOS
        StringSplit, SOLOFieldUpgrade, SOLOFieldUpgradeXY, `,
    } else {
        FieldUpgradeXY := FieldUpgradePOS
        StringSplit, FieldUpgrade, FieldUpgradeXY, `,
    }

    FieldUpgradeKey := FieldUpgradeKey
    
    ; Provide feedback to the user
    SendMessage("Values have successfully been updated. Have fun!")
    return

;;;;;;;;;;;;;;;;;;;;;
;;;; togglables ;;;;;
;;;;;;;;;;;;;;;;;;;;;

toggleSolo:
    soloToggle := !soloToggle
    if (soloToggle) {
        GuiControl,, Solo, Solo: ON
        ; Prevent any further logic if toggle is true (script is running)
        if (!toggle) {
            SendMessage("If you are in Solo Squads this won't work.")
        }
    } else {
        GuiControl,, Solo, Solo: OFF
    }
return

toggleSpin:
    spinToggle := !spinToggle
    if (spinToggle) {
        GuiControl,, spinText, ON
        spinIsEnabled := true
        if (!toggle) {
            SendMessage("Make sure you are in Directed mode and in the Beamsmasher Room`nLine yourself up with the middle of the Window and line your cursor up and then Enable the script")
        }
    } else {
        spinIsEnabled := false
        GuiControl,, spinText, OFF
    }
return

;;;;;;;;;;;;;;
;;;; misc ;;;;
;;;;;;;;;;;;;;

SendMessage(message) {
    ahkTitle := RegExReplace(A_ScriptName, "\.ahk$", "")
    ; Display a message box with the given title and message
    MsgBox, 0, %ahkTitle%, %message%, 3
}

CloseMsgBox() {
    ; Find and close the MsgBox with the title "pccoach"
    WinClose, pccoach
}


UpdateTime:
    elapsed := (A_TickCount - startTime) // 1000  ; Calculate elapsed time in seconds
    hours := elapsed // 3600
    minutes := (elapsed // 60) - (hours * 60)
    seconds := Mod(elapsed, 60)
    formattedTime := Format("{:02}:{:02}:{:02}", hours, minutes, seconds)
    GuiControl,, Time, Running Time: %formattedTime%
return

;;;;;;;;;;;;;;;;;;;;;;;
CloseScript:        ;;;;;;;;;;;
GuiClose:       ;;;; exit code ;;;;
    ExitApp         ;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;

F5::
ExitApp

;;;;;;;;;;;;;;;;;;;;;;;;
;;;; mouse function ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;

isMouseXY := false
mouseTracking := false

F6::
    ; Toggle mouseTracking on F6 press
    mouseTracking := !mouseTracking
    
    if (mouseTracking) {
        ; If mouseTracking is enabled, start tracking
        SendMessage("Make sure you click onto BO6 after enabling`nIf you don't then it won't show the proper value")
        GuiControl, Show, MouseStop
        GuiControl,, MousePosToggleLabel, Enabled
        SetTimer, trackMouseXY, 10
    } else {
        ; If mouseTracking is disabled, stop tracking
        GuiControl,, MousePosToggleLabel, Disabled
        SetTimer, trackMouseXY, Off
        GuiControl, Hide, MouseStop
        ToolTip  ; Hide tooltip when tracking is off
    }
Return

toggleMouseXYButton:
    ; Toggle isMouseXY state and track mouse position
    isMouseXY := !isMouseXY

    if (isMouseXY) {
        ; Enable mouse tracking
        SendMessage("Make sure you click onto BO6 after enabling`nIf you don't then it won't show the proper value")
        GuiControl,, MousePosToggleLabel, Enabled
        SetTimer, trackMouseXY, 10
        mouseTracking := true
    } else {
        ; Disable mouse tracking
        mouseTracking := false
        GuiControl,, MousePosToggleLabel, Disabled
        SetTimer, trackMouseXY, Off
        ToolTip  ; Hide tooltip when tracking is off
    }
Return

trackMouseXY:
    ; Only track the mouse if mouseTracking is enabled
    if (mouseTracking) {
        MouseGetPos, xPos, yPos
        GuiControl,, MousePOS, %xPos%, %yPos% 
        ToolTip, X: %xPos%`nY: %yPos%
    } else {
        ToolTip  ; Hide tooltip if mouseTracking is off
    }
Return


WatchCursor:
    MouseGetPos, iks, igr  ; Get current mouse position

    ; Check if the cursor is within the defined region
    if (iks <= 950 and iks >= 920 and igr <= 25 and igr >= 1)
    {
        if (!tooltipVisible)  ; Only show tooltip if it's not already visible
        {
            Tooltip, THIS IS A TEST!!!
            tooltipStartTime := A_TickCount  ; Start the timer when the tooltip is displayed
            tooltipVisible := true  ; Flag to track that tooltip is visible
        }
    }
    else
    {
        if (tooltipVisible and A_TickCount - tooltipStartTime > 1000)  ; Tooltip visible for 1 second
        {
            Tooltip  ; Hide the tooltip by displaying a blank one
            tooltipVisible := false  ; Reset tooltip state
        }
    }
return