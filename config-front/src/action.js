// 分组、根据 value 获取 label 数据
import { bindWindow } from './util';
import _, { join } from 'lodash'

export const specialActions = [
    {
        label: "绑定当前窗口到这个键",
        generateValue: (routeName, currentKey) => bindWindow(routeName, currentKey),
    },
    {
        label: "取消当前窗口的键绑定",
        generateValue: (routeName, currentKey) => "bindOrActivate_unbind()",
    },
    {
        label: "关闭所有同类窗口",
        generateValue: (routeName, currentKey) => "close_same_class_window()",
    },
]


export const windowActions1 = [
    { label: "关闭窗口", value: "SmartCloseWindow()" },
    { label: "切换到上一个窗口", value: "send, !{tab}" },
    { label: "在当前程序的窗口间切换", value: "SwitchWindows()" },
    { label: "窗口管理器(EDSF切换、X关闭、空格选择)", value: "action_enter_task_switch_mode()", }, // 别改位置, 其他地方依赖 windowActions1[4]
    { label: "上一个虚拟桌面", value: "send, {LControl down}{LWin down}{Left}{LWin up}{LControl up}", },
    { label: "下一个虚拟桌面", value: "send, {LControl down}{LWin down}{Right}{LWin up}{LControl up}", },
    { label: "移动窗口到下一个显示器", value: "send, #+{right}" },
    { label: "模拟 Alt+Tab 热键", value: "SystemAltTab()" },
]

export const windowActions2 = [
    { label: "窗口最大化", value: "winMaximizeIgnoreDesktop()" },
    { label: "窗口最小化", value: "winMinimizeIgnoreDesktop()" },
    { label: "窗口居中(1200x800)", value: "center_window_to_current_monitor(1200, 800)", },
    { label: "窗口居中(1370x930)", value: "center_window_to_current_monitor(1370, 930)", },
    { label: "切换窗口置顶状态", value: "ToggleTopMost()" },
    { label: "上一个窗口 (Alt+Esc)", value: "send, !{Esc}" },
    { label: "下一个窗口 (Shift+Alt+Esc)", value: "send, +!{Esc}" },
    { label: "模拟 Shift+Alt+Tab 热键", value: "SystemShiftAltTab()" },
]

export const windowActions4 = [
    { label: "关闭窗口 (直接杀进程)", value: "close_window_processes()" },
]


export const mouseActions = [
    { label: "鼠标上移", value: "鼠标上移" },
    { label: "鼠标下移", value: "鼠标下移" },
    { label: "鼠标左移", value: "鼠标左移" },
    { label: "鼠标右移", value: "鼠标右移" },
]

export const mouseActions2 = [
    // { label: "鼠标左上移动", value: "鼠标左上移动" },
    // { label: "鼠标右上移动", value: "鼠标右上移动" },
    // { label: "鼠标左下移动", value: "鼠标左下移动" },
    // { label: "鼠标右下移动", value: "鼠标右下移动" },
    { label: "移动鼠标到窗口中心", value: "移动鼠标到窗口中心" },
    { label: "移动鼠标到「 输入焦点 」", value: "移动鼠标到「 输入焦点 」" },
]
export const scrollActions = [
    { label: "滚轮上滑", value: "滚轮上滑" },
    { label: "滚轮下滑", value: "滚轮下滑" },
    { label: "滚轮左滑", value: "滚轮左滑" },
    { label: "滚轮右滑", value: "滚轮右滑" },
]
export const clickActions = [
    { label: "鼠标左键", value: "鼠标左键" },
    { label: "鼠标右键", value: "鼠标右键" },
    { label: "鼠标中键", value: "鼠标中键" },
    { label: "鼠标左键按下", value: "鼠标左键按下" },
    { label: "鼠标左键双击 (选中单词)", value: "鼠标左键双击 (选中单词)" },
    { label: "鼠标左键三击 (选中一行)", value: "鼠标左键三击 (选中一行)" },
    { label: "让当前窗口进入拖动模式", value: "让当前窗口进入拖动模式" },
]

export const textFeatures1 = [
    { label: "把选中的文字设为红色", value: 'setColor("#D05")' },
    { label: "把选中的文字设为紫色", value: 'setColor("#b309bb")' },
    { label: "把选中的文字设为粉色", value: 'setColor("#FF00FF")' },
    { label: "把选中的文字设为蓝色", value: 'setColor("#2E66FF")' },
    { label: "把选中的文字设为绿色", value: 'setColor("#080")' },
    { label: "对齐选中的文本", value: 'action_align_text()', },
    { label: "在中英文之间添加空格", value: "actionAddSpaceBetweenEnglishChinese()", },
    { label: "用剪切板收集文本", value: 'ActivateOrRun("用剪切板收集文本", "bin\\ahk.exe", "bin\\CollectText.ahk")', },
]
export const textFeatures2 = [

    { label: "方向键 - 上", value: "send, {blind}{up}" },
    { label: "方向键 - 下", value: "send, {blind}{down}" },
    { label: "方向键 - 左", value: "send, {blind}{left}" },
    { label: "方向键 - 右", value: "send, {blind}{right}" },
    { label: "光标移动 - 行首 (Home)", value: "send, {blind}{home}" },
    { label: "光标移动 - 行尾 (End)", value: "send, {blind}{end}" },
    { label: "光标移动 - 上一个单词", value: "send, {blind}^{left}" },
    { label: "光标移动 - 下一个单词", value: "send, {blind}^{right}" },
    { label: "删除 - 到行首", value: "sendevent, +{home}{bs}" },
    { label: "删除 - 到行尾", value: "sendevent, +{end}{bs}" },
    { label: "删除 - 一个单词", value: "sendevent, ^{bs}" },

]

export const textFeatures3 = [
    { label: "常用键 - 右键菜单", value: "send, {appskey}" },
    { label: "常用键 - Esc", value: "send, {esc}" },
    { label: "常用键 - BackSpace", value: "send, {blind}{bs}" },
    { label: "常用键 - Enter", value: "send, {blind}{enter}" },
    { label: "常用键 - Space", value: "send, {blind}{space}" },
    { label: "常用键 - Tab", value: "send, {blind}{tab}" },
    { label: "常用键 - Shift + Tab", value: "send, {blind}+{tab}" },
    { label: "常用键 - Delete", value: "send, {blind}{del}" },
    { label: "其他键 - Insert", value: "send, {blind}{insert}" },
    { label: "「 Shift 键 」", value: "action_hold_down_shift_key()" },
    { label: "「 右 Shift 键 」", value: "action_hold_down_Rshift_key()" },
]

export const textFeatures4 = [
    { label: "选中当前行", value: "sendevent, {home}+{end}" },
    { label: "Ctrl + C (复制)", value: "send, ^c" },
    { label: "Ctrl + X (剪切)", value: "send, ^x" },
    { label: "Ctrl + V (粘贴)", value: "send, ^v" },
    { label: "Ctrl + Z (撤销)", value: "send, ^z" },
    { label: "Ctrl + Y (重做)", value: "send, ^y" },
    { label: "Ctrl + Tab (切换标签)", value: "send, ^{tab}" },
    { label: "Ctrl + Shift + Tab (同上)", value: "send, ^+{tab}" },
]



export const getLabelByValue = [
    ...windowActions1, ...windowActions2, ...mouseActions, ...scrollActions, ...clickActions,
    ...textFeatures1, ...textFeatures2, ...textFeatures3, ...textFeatures4,
].reduce((a, b) => { a[b.value] = b.label; return a }, {})