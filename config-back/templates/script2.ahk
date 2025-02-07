﻿#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 70
#NoTrayIcon
#WinActivateForce               ; 解决「 winactivate 最小化的窗口时不会把窗口放到顶层(被其他窗口遮住) 」
#InstallKeybdHook               ; 可能是 ahk 自动卸载 hook 导致的丢失 hook,  如果用这行指令, ahk 是否就不会卸载 hook 了呢?
#include bin/functions.ahk
#include bin/actions.ahk

{{ define "keymapToAhk" }}
{{- range toList . -}}
{{ .Prefix }}{{ escapeAhkHotkey .Key }}::{{ .Value }}
{{ end }}
{{ end }}

SetWorkingDir %A_ScriptDir%\..
{{ if .Settings.runAsAdmin -}}
requireAdmin()
{{- end }}
closeOldInstance()

SetBatchLines -1
ListLines Off
process, Priority,, H
; 使用 sendinput 时,  通过 alt+3+j 输入 alt+1 时,  会发送 ctrl+alt
SendMode Input
; SetKeyDelay, 0
; SetMouseDelay, 0

SetMouseDelay, 0  ; 发送完一个鼠标后不会 sleep
SetDefaultMouseSpeed, 0
coordmode, mouse, screen
settitlematchmode, 2

; win10、win11 任务切换、任务视图
GroupAdd, TASK_SWITCH_GROUP, ahk_class MultitaskingViewFrame
GroupAdd, TASK_SWITCH_GROUP, ahk_class XamlExplorerHostIslandWindow
{{ range .windowSelectors -}}
{{ if .groupCode}}{{ .groupCode }}
{{ end }}
{{- end }}

scrollOnceLineCount := {{ .Settings.scrollOnceLineCount }}
scrollDelay1 = {{ concat "T" .Settings.scrollDelay1 }}
scrollDelay2 = {{ concat "T" .Settings.scrollDelay2 }}

{{ if .Settings.showMouseMovePrompt }}
global mouseMovePrompt := newMouseMovePromptWindow()
{{ end }}

exitMouseModeAfterClick := {{ .Settings.exitMouseModeAfterClick }}
fastMoveSingle := {{ .Settings.fastMoveSingle }}
fastMoveRepeat := {{ .Settings.fastMoveRepeat }}
slowMoveSingle := {{ .Settings.slowMoveSingle }}
slowMoveRepeat := {{ .Settings.slowMoveRepeat }}
moveDelay1 = {{ concat "T" .Settings.moveDelay1 }}
moveDelay2 = {{ concat "T" .Settings.moveDelay2 }}

SemicolonAbbrTip := true
keymapLockState := {}

allHotkeys := []
{{ if .Settings.Mode3 }}allHotkeys.Push("*3"){{ end }}
{{ if .Settings.Mode9 }}allHotkeys.Push("*9"){{ end }}
{{ if .Settings.CommaMode }}allHotkeys.Push("*,"){{ end }}
{{ if .Settings.DotMode }}allHotkeys.Push("*."){{ end }}
{{ if .Settings.JMode }}allHotkeys.Push("*j"){{ end }}
{{ if .Settings.CapslockMode }}allHotkeys.Push("*capslock"){{ end }}
{{ if .Settings.SemicolonMode }}allHotkeys.Push("*;"){{ end }}
{{ if .Settings.LButtonMode }}allHotkeys.Push("~LButton"){{ end }}
{{ if .Settings.RButtonMode }}allHotkeys.Push("RButton"){{ end }}
{{ if .Settings.SpaceMode }}allHotkeys.Push("*Space"){{ end }}
{{ if .Settings.TabMode }}allHotkeys.Push("$Tab"){{ end }}
{{ if .Settings.AdditionalMode1 }}allHotkeys.Push("{{ .Settings.AdditionalMode1Info.Hotkey }}"){{ end }}
{{ if .Settings.AdditionalMode2 }}allHotkeys.Push("{{ .Settings.AdditionalMode2Info.Hotkey }}"){{ end }}

Menu, Tray, NoStandard
Menu, Tray, Add, 暂停, trayMenuHandler
Menu, Tray, Add, 退出, trayMenuHandler
Menu, Tray, Add, 重启程序, trayMenuHandler
Menu, Tray, Add, 打开设置, trayMenuHandler 
Menu, Tray, Add, 帮助文档, trayMenuHandler 
Menu, Tray, Add, 查看窗口标识符, trayMenuHandler 
Menu, Tray, Default, 暂停
Menu, Tray, Click, 1
Menu, Tray, Add 

Menu, Tray, Icon
Menu, Tray, Icon, bin\logo.ico,, 1
Menu, Tray, Tip, MyKeymap 1.2.7 by 咸鱼阿康
; processPath := getProcessPath()
; SetWorkingDir, %processPath%


CoordMode, Mouse, Screen
; 多显示器不同缩放比例导致的问题,  https://www.autohotkey.com/boards/viewtopic.php?f=14&t=13810
DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")


global typoTip := new TypoTipWindow()

semiHook := InputHook("", "{CapsLock}{BackSpace}{Esc}{;}{Space}", {{ .SemicolonAbbrKeys|join ","|ahkString }})
semiHook.KeyOpt("{CapsLock}", "S")
semiHook.OnChar := Func("onSemiHookChar")
semiHook.OnEnd := Func("onSemiHookEnd")
capsHook := InputHook("", "{CapsLock}{BackSpace}{Esc}", {{ .CapslockAbbrKeys|join ","|ahkString }})
capsHook.KeyOpt("{CapsLock}", "S")
capsHook.OnChar := Func("onCapsHookChar")
capsHook.OnEnd := Func("onCapsHookEnd")

#include data/custom_functions.ahk
return

^F21::
    Suspend, Permit
    MyRun2(run_target, run_args, run_workingdir)
    Return
^F22::
    Suspend, Permit
    ActivateOrRun2(run_to_activate, run_target, run_args, run_workingdir, run_run_as_admin)
    Return

{{ .Settings.KeyMapping }}

{{ range toList .CustomHotkeys -}}
{{ if and .Key (or (contains .Value "toggleSuspend()") (contains .Value "ReloadProgram()")) -}}
{{ escapeAhkHotkey .Key }}::{{ .Value }}
{{- end }}
{{ end }}

{{ if .Settings.CapslockMode -}}
*capslock::
    start_tick := A_TickCount
    thisHotkey := A_ThisHotkey
    disableOtherHotkey(thisHotkey)
    CapslockMode := true
    ResetCurrentModeLockState("CapslockMode")
    keywait capslock
    CapslockMode := false
    if (A_ThisHotkey = "*capslock" && A_PriorKey = "CapsLock" && (A_TickCount - start_tick < 350)) {
        {{ (index .SpecialKeys "Caps Up").value }}
    }
    enableOtherHotkey(thisHotkey)
    return
{{ end }}


{{ if .Settings.JMode }}
*j::
    start_tick := A_TickCount
    thisHotkey := A_ThisHotkey
    disableOtherHotkey(thisHotkey)
    JMode := true
    ResetCurrentModeLockState("JMode")
    DisableCapslockKey := true
    keywait j
    JMode := false
    DisableCapslockKey := false
    if (A_PriorKey = "j" && (A_TickCount - start_tick < 300))
            send,  {blind}j
    enableOtherHotkey(thisHotkey)
    return
{{ end }}


{{ if .Settings.SemicolonMode }}
*`;::
    start_tick := A_TickCount
    thisHotkey := A_ThisHotkey
    disableOtherHotkey(thisHotkey)
    SemicolonMode := true
    ResetCurrentModeLockState("SemicolonMode")
    DisableCapslockKey := true
    keywait `; 
    SemicolonMode := false
    DisableCapslockKey := false
    if (A_PriorKey = ";" && (A_TickCount - start_tick < 300)) {
         {{ (index .SpecialKeys "; Up").value }}
    }
    enableOtherHotkey(thisHotkey)
    return
{{ end }}

{{ if .Settings.Mode3 }}
*3::
    start_tick := A_TickCount
    thisHotkey := A_ThisHotkey
    disableOtherHotkey(thisHotkey)
    Mode3 := true
    ResetCurrentModeLockState("Mode3")
    keywait 3 
    Mode3 := false
    if (A_PriorKey = "3" && (A_TickCount - start_tick < 300))
        send, {blind}3 
    enableOtherHotkey(thisHotkey)
    return
{{ end }}
{{ if .Settings.Mode9 }}
*9::
    start_tick := A_TickCount
    thisHotkey := A_ThisHotkey
    disableOtherHotkey(thisHotkey)
    Mode9 := true
    ResetCurrentModeLockState("Mode9")
    keywait 9 
    Mode9 := false
    if (A_PriorKey = "9" && (A_TickCount - start_tick < 300))
        send, {blind}9 
    enableOtherHotkey(thisHotkey)
    return
{{ end }}

{{ if .Settings.CommaMode }}
*,::
    start_tick := A_TickCount
    thisHotkey := A_ThisHotkey
    disableOtherHotkey(thisHotkey)
    CommaMode := true
    ResetCurrentModeLockState("CommaMode")
    keywait `, 
    CommaMode := false
    if (A_PriorKey = "," && (A_TickCount - start_tick < 300))
        send, {blind}`, 
    enableOtherHotkey(thisHotkey)
    return
{{ end }}

{{ if .Settings.DotMode }}
*.::
    start_tick := A_TickCount
    thisHotkey := A_ThisHotkey
    disableOtherHotkey(thisHotkey)
    DotMode := true
    ResetCurrentModeLockState("DotMode")
    keywait `. 
    DotMode := false
    if (A_PriorKey = "." && (A_TickCount - start_tick < 300))
        send, {blind}`. 
    enableOtherHotkey(thisHotkey)
    return
{{ end }}

{{ if .Settings.AdditionalMode1 }}
{{ .Settings.AdditionalMode1Info.Hotkey }}::
    start_tick := A_TickCount
    thisHotkey := A_ThisHotkey
    disableOtherHotkey(thisHotkey)
    AdditionalMode1 := true
    ResetCurrentModeLockState("AdditionalMode1")
    keywait {{ .Settings.AdditionalMode1Info.WaitKey }}
    AdditionalMode1 := false
    if (A_PriorKey = "{{ .Settings.AdditionalMode1Info.PriorKey }}" && (A_TickCount - start_tick < 300)) {
        {{ .Settings.AdditionalMode1Info.Send }}
    }
    enableOtherHotkey(thisHotkey)
    return
{{ end }}

{{ if .Settings.AdditionalMode2 }}
{{ .Settings.AdditionalMode2Info.Hotkey }}::
    start_tick := A_TickCount
    thisHotkey := A_ThisHotkey
    disableOtherHotkey(thisHotkey)
    AdditionalMode2 := true
    ResetCurrentModeLockState("AdditionalMode2")
    keywait {{ .Settings.AdditionalMode2Info.WaitKey }}
    AdditionalMode2 := false
    if (A_PriorKey = "{{ .Settings.AdditionalMode2Info.PriorKey }}" && (A_TickCount - start_tick < 300)) {
        {{ .Settings.AdditionalMode2Info.Send }}
    }
    enableOtherHotkey(thisHotkey)
    return
{{ end }}

{{ if .Settings.SpaceMode }}
*Space::
    start_tick := A_TickCount
    thisHotkey := A_ThisHotkey
    disableOtherHotkey(thisHotkey)
    SpaceMode := true
    ResetCurrentModeLockState("SpaceMode")
    keywait Space 
    SpaceMode := false
    if (A_PriorKey = "Space" && (A_TickCount - start_tick < 300))
        send, {blind}{Space} 
    enableOtherHotkey(thisHotkey)
    return
{{ end }}

{{ if .Settings.TabMode }}
$Tab::
    start_tick := A_TickCount
    thisHotkey := A_ThisHotkey
    disableOtherHotkey(thisHotkey)
    TabMode := true
    ResetCurrentModeLockState("TabMode")
    keywait Tab 
    TabMode := false
    if (A_PriorKey = "Tab" && (A_TickCount - start_tick < 300))
        send, {blind}{Tab} 
    enableOtherHotkey(thisHotkey)
    return
{{ end }}

{{ if .Settings.RButtonMode }}
RButton::
enterRButtonMode()
{
	global RButtonMode
    start_tick := A_TickCount
    thisHotkey := A_ThisHotkey
    RButtonMode := true
	keywait, RButton
    RButtonMode := false
    if (A_PriorKey = "RButton" && (A_TickCount - start_tick < 350)) {
        ; 如果在系统设置中交换了左右键,  那么需要发送左键才能打开右键菜单
        SysGet, swapMouseButton, 23
        if swapMouseButton {
            send, {blind}{LButton}
        } else {
            send, {blind}{RButton}
        }
    }
}
{{ end }}


{{ if .Settings.LButtonMode }}
~LButton::
enterLButtonMode()
{
	global LButtonMode
    LButtonMode := true
    keywait LButton
    LButtonMode := false
    return
}
{{ end }}




{{ if .Settings.JMode }}
#if JModeK
*k::return
{{ template "keymapToAhk" .JModeK }}
#if JMode
*k::enterJModeK()
{{ template "keymapToAhk" .JMode }}
{{ end }}

{{ if .Settings.SemicolonMode }}
#if SemicolonMode
{{ template "keymapToAhk" .Semicolon }}
{{ end }}

{{ if .Settings.SpaceMode }}
#if SpaceMode
{{ template "keymapToAhk" .SpaceMode }}
{{ end }}

{{ if .Settings.TabMode }}
#if TabMode
{{ template "keymapToAhk" .TabMode }}
{{ end }}

{{ if .Settings.Mode3 }}
#if Mode3
{{ template "keymapToAhk" .Mode3 }}
{{ end }}

{{ if .Settings.Mode9 }}
#if Mode9
{{ template "keymapToAhk" .Mode9 }}
{{ end }}

{{ if .Settings.CommaMode }}
#if CommaMode
{{ template "keymapToAhk" .CommaMode }}
{{ end }}

{{ if .Settings.DotMode }}
#if DotMode
{{ template "keymapToAhk" .DotMode }}
{{ end }}

{{ if .Settings.AdditionalMode1 }}
#if AdditionalMode1
{{ .Settings.AdditionalMode1Info.WaitKey }}::return
{{ template "keymapToAhk" .AdditionalMode1 }}
{{ end }}

{{ if .Settings.AdditionalMode2 }}
#if AdditionalMode2
{{ .Settings.AdditionalMode2Info.WaitKey }}::return
{{ template "keymapToAhk" .AdditionalMode2 }}
{{ end }}

{{ if .Settings.CapslockMode }}
#if CapslockMode
{{ template "keymapToAhk" .Capslock }}

{{ if .Settings.enableCapsF }}
f::
    FMode := true
    CapslockMode := false
    SLOWMODE := false
    keywait f
    FMode := false
    if keymapLockState.locked {
        CapslockMode := true
    }
    return
{{ end }}

{{ if .Settings.enableCapsSpace }}
space::
    CapslockSpaceMode := true
    CapslockMode := false
    SLOWMODE := false
    keywait space
    CapslockSpaceMode := false
    if keymapLockState.locked {
        CapslockMode := true
    }
    return
{{ end }}
{{- end }}

#if SLOWMODE
{{ template "keymapToAhk" .MouseMoveMode }}
Esc::exitMouseMode()
*Space::exitMouseMode()

{{ if .Settings.CapslockMode -}}
#if FMode
f::return
{{ template "keymapToAhk" .CapslockF }}

#if CapslockSpaceMode
space::return
{{ template "keymapToAhk" .CapslockSpace }}

#if DisableCapslockKey
*capslock::return
*capslock up::return
{{ end }}

{{ if .Settings.LButtonMode }}
#if LButtonMode
{{ template "keymapToAhk" .LButtonMode }}
{{ end }}

{{ if .Settings.RButtonMode }}
#if RButtonMode
{{ template "keymapToAhk" .RButtonMode }}
{{ end }}

#If TASK_SWITCH_MODE
{{ .Settings.windowSwitcherKeymap }}

#if !keymapIsActive
{{ range toList .CustomHotkeys -}}
{{ if and .Key (not (or (contains .Value "toggleSuspend()") (contains .Value "ReloadProgram()"))) -}}
{{ escapeAhkHotkey .Key }}::{{ .Value }}
{{- end }}
{{ end }}
#If




execSemicolonAbbr(typo) {
    switch typo 
    {
    {{ range toList .SemicolonAbbr -}}
        case {{ .Key|ahkString }}:
            {{ .Value }}
    {{ end -}}
        default:
            return false
    }
    return true
}

execCapslockAbbr(typo) {
    switch typo 
    {
    {{ range toList .CapslockAbbr -}}
        case {{ .Key|ahkString }}:
            {{ .Value }}
    {{ end -}}
        default:
            return false
    }
    return true
}




{{ .all_ahk_funcs|join "\n" }}

{{ range .send_key_functions -}}
{{ . }}
{{ end }}