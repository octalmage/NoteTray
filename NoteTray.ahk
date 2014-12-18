DetectHiddenWindows On 
#singleinstance force
fileread,text,dat
gui,+resize
gui,add,edit ,h200 w300 vnoteedit,%text%
gui,show,,NoteTray
gui,+lastfound
Menu, Tray, NoStandard
Menu, Tray, add, Exit, Exit
Menu, Tray, Add, Restore, Restore
Menu, Tray, Default, Restore
winid:=winexist()
WinGet, hw_notepad, ID, ahk_id %winid%

WinHide
WinSet, ExStyle, +0x80 ; 0x80 is WS_EX_TOOLWINDOW
WinShow 


return

GuiSize:
;SetFormat, Integer, Hex
DllCall("QueryPerformanceCounter", "Int64P", t0)
Anchor("noteedit", "wh")

GuiWidth := A_GuiWidth
DllCall("QueryPerformanceCounter", "Int64P", t1)
;MsgBox, % clipboard := (t1 - t0) / freq
Return

guiclose:
gui,submit
filedelete,dat
fileappend,%noteedit%,dat
return

~esc::
if winactive("NoteTray")
{
gosub guiclose
}


return

exit:
gui,submit
filedelete,dat
fileappend,%noteedit%,dat
exitapp
return

Restore:
   Gui, 1:Show
Return

Anchor(cl, a = "", r = false) {
	static d, g, sd = 12, sg := 13, sc = 0, k = 0xffff, iz = 0, bx, by
	If !iz
		iz := 1, VarSetCapacity(g, sg * 99, 0), VarSetCapacity(d, sd * 200, 0)
	Gui, %A_Gui%:+LastFound
	If cl is xdigit
		c = %cl%
	Else {
		GuiControlGet, c, Hwnd, %cl%
		If ErrorLevel
			ControlGet, c, Hwnd, , %cl%
	}
	If !(A_Gui or c) and a
		Return
	cg := (A_Gui - 1) * sg
	Loop, %sc%
		If NumGet(d, z := (A_Index - 1) * sd) = c {
			p := NumGet(d, z + 4, "UInt64"), l := 1
				, x := p >> 48, y := p >> 32 & k, w := p >> 16 & k, h := p & k
				, gw := (gh := NumGet(g, cg + 1)) >> 16, gh &= k
			If a =
				Break
			Loop, Parse, a, xywh
				If A_Index > 1
				{
					v := SubStr(a, l, 1)
					If v in y,h
						n := A_GuiHeight - gh
					Else n := A_GuiWidth - gw
					b = %A_LoopField%
					%v% += n * (b + 0 ? b : 1), l += StrLen(A_LoopField) + 1
				}
				DllCall("SetWindowPos", "UInt", c, "Int", 0
					, "Int", x, "Int", y, "Int", w, "Int", h, "Int", 4)
				If r
					VarSetCapacity(rc, 16, 0), NumPut(x, rc, 0, "Int"), NumPut(y, rc, 4, "Int")
						, NumPut(w + x, rc, 8, "Int"), NumPut(h + y, rc, 12, "Int")
						, DllCall("InvalidateRect", "UInt", WinExist(), "UInt", &rc, "UInt", true)
				Return
		}
	ControlGetPos, x, y, w, h, , ahk_id %c%
	If !p {
		If NumGet(g, cg, "UChar") != A_Gui {
			WinGetPos, , , , gh
			gh -= A_GuiHeight
			VarSetCapacity(bdr, 63, 0)
				, DllCall("GetWindowInfo", "UInt", WinExist(), "UInt", &bdr)
				, NumPut(A_Gui, g, cg, "UChar")
				, NumPut(A_GuiWidth << 16 | A_GuiHeight, g, cg + 1, "UInt")
				,  NumPut((bx := NumGet(bdr, 48)) << 32
				| (by := gh - NumGet(bdr, 52)), g, cg + 5, "UInt64")
		}
		Else b := NumGet(g, cg + 5, "UInt64"), bx := b >> 32, by := b & 0xffffffff
	}
	s := x - bx << 48 | y - by << 32 | w << 16 | h
	If p
		NumPut(s, d, z + 4, "UInt64")
	Else NumPut(c, d, sc * 12), NumPut(s, d, sc * 12 + 4, "UInt64"), sc++
}