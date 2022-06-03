				.code
Dialog			proto			:HWND, :UINT, :WPARAM, :LPARAM

MainWindow		proc			Hndl:HINSTANCE, PrevHndl:HINSTANCE, CmdLine:LPSTR, CmdParam:DWORD

				local			wc:WNDCLASSEX
				local			WHandle:HWND
				local			msg:MSG

				mov				wc.cbSize, SIZEOF WNDCLASSEX
				mov				wc.style, CS_VREDRAW or CS_HREDRAW
				mov				wc.lpfnWndProc, offset WindowMsgProc
				mov				wc.cbClsExtra, NULL
				mov				wc.cbWndExtra, NULL
				mov				eax, Hndl
				mov				wc.hInstance, eax
				mov				wc.hIcon, NULL
				invoke			LoadCursor, NULL, IDC_ARROW
				mov				wc.hCursor, eax
				mov				wc.hbrBackground, COLOR_WINDOW
				mov				wc.lpszMenuName, offset MenuName
				mov				wc.lpszClassName, offset ClassName
				mov				wc.hIconSm, NULL

				invoke			RegisterClassEx, addr wc 											;addr is used for local variables
				invoke			CreateWindowEx, NULL,\
												offset ClassName,\
												offset Program,\
												WS_OVERLAPPEDWINDOW,\
												CW_USEDEFAULT,\
												CW_USEDEFAULT,\
												1280,\
												720,\
												NULL,\
												NULL,\
												Hndl,\
												NULL
				mov				WHandle, eax
				invoke			ShowWindow, WHandle, CmdParam
				invoke			UpdateWindow, WHandle

				.WHILE			TRUE
					invoke			GetMessage, addr msg, NULL, 0, 0
				.BREAK			.IF (eax == 0)
					invoke			TranslateMessage, addr msg
					invoke			DispatchMessage, addr msg
				.ENDW

				mov				eax, msg.wParam
				ret

MainWindow		endp

WindowMsgProc	proc			wHandle:DWORD, Msg:DWORD, wParam:DWORD, lParam:DWORD
				local			paint_structure:PAINTSTRUCT
				local			hdc:HDC
				local			draw_rect:RECT
				local			center:POINT
				local			step:POINT
				local			cnt:POINT

				push			esi
				push			edi
				push			ebx

				.IF				(Msg == WM_DESTROY)
					invoke			PostQuitMessage, NULL
				.ENDIF

				.IF				(Msg == WM_COMMAND)
					.IF				(wParam == BUTTON_EXIT)
						invoke			DestroyWindow, wHandle
					.ELSEIF			(wParam == BUTTON_ABOUT) 
						invoke			MessageBox, NULL, offset AboutMSG, offset Program, MB_OK or MB_TASKMODAL or MB_ICONQUESTION
					.ELSEIF			(wParam == BUTTON_SETTINGS)
param_loop:				invoke  		DialogBoxParam, Handle, WINDOW_SETTINGS, wHandle, offset Dialog, NULL	
						cmp				eax, 0
						jne				param_loop
						invoke			InvalidateRect, wHandle, NULL, 1
					.ENDIF
				.ENDIF

				.IF				(Msg == WM_PAINT)
					invoke			BeginPaint, wHandle, addr paint_structure
					mov				hdc, eax
					invoke			GetClientRect, wHandle, addr draw_rect

					mov				eax, bounds.X_right
					mov				ebx, bounds.X_left
					sub				eax, ebx
					mov				cnt.x, eax		;how many intervals

					mov				eax, bounds.Y_up
					mov				ebx, bounds.Y_down
					sub				eax, ebx
					mov				cnt.y, eax		;how many intervals

					mov				eax, draw_rect.right
					xor				edx, edx
					div				cnt.x
					mov				step.x, eax		;pixels on an interval

					mov				eax, draw_rect.bottom
					xor				edx, edx
					div				cnt.y
					mov				step.y, eax		;pixels on an interval

					mov				eax, bounds.X_left
					neg				eax
					mul				step.x
					mov				center.x, eax	;center in pixels

					mov				eax, bounds.Y_up
					mul				step.y
					mov				center.y, eax	;center in pixels

					invoke			DrawGrid, hdc, draw_rect, center, step, cnt
					invoke			DrawGraph, hdc, center, step, cnt
					invoke			UpdateWindow, wHandle
				.ELSE
					invoke			DefWindowProc, wHandle, Msg, wParam, lParam
				.ENDIF

				pop				ebx
				pop				edi
				pop				esi

				ret
WindowMsgProc	endp

Dialog			proc			DialogHandle:HWND, Msg:UINT, wParam:WPARAM, lParam:LPARAM
				local			tr:BYTE

				.IF				(Msg == WM_INITDIALOG)
					invoke			SetDlgItemInt, DialogHandle, EDITBOX_X_LEFT, bounds.X_left, TRUE
					invoke			SetDlgItemInt, DialogHandle, EDITBOX_X_RIGHT, bounds.X_right, TRUE
					invoke			SetDlgItemInt, DialogHandle, EDITBOX_Y_UP, bounds.Y_up, TRUE
					invoke			SetDlgItemInt, DialogHandle, EDITBOX_Y_DOWN, bounds.Y_down, TRUE
					mov				eax, 1
				.ELSEIF			(Msg == WM_COMMAND)
					.IF				(wParam == BUTTON_OK)

						invoke			GetDlgItemInt, DialogHandle, EDITBOX_X_RIGHT, addr tr, 1
						cmp				tr, NULL
						je				invXError
						cmp				eax, 1000
						jg				invXError
						cmp				eax, 0
						jl				invXError
						mov				bounds.X_right, eax

						invoke			GetDlgItemInt, DialogHandle, EDITBOX_X_LEFT, addr tr, 1
						cmp				tr, NULL
						je				invXError
						cmp				eax, bounds.X_right
						jge				invXError
						cmp				eax, -1000
						jl				invXError
						cmp				eax, 0
						jg				invXError
						mov				bounds.X_left, eax

						invoke			GetDlgItemInt, DialogHandle, EDITBOX_Y_UP, addr tr, 1
						cmp				tr, NULL
						je				invYError
						cmp				eax, 1000
						jg				invYError
						cmp				eax, 0
						jl				invYError
						mov				bounds.Y_up, eax

						invoke			GetDlgItemInt, DialogHandle, EDITBOX_Y_DOWN, addr tr, 1
						cmp				tr, NULL
						je				invYError
						cmp				eax, bounds.Y_up
						jge				invYError
						cmp				eax, -1000
						jl				invYError
						cmp				eax, 0
						jg				invYError
						mov				bounds.Y_down, eax
						jmp				OK

invXError:				invoke			MessageBox, NULL, offset InvXMSG, offset Program, MB_OK or MB_TASKMODAL or MB_ICONERROR															
						mov				eax, 1
						ret

invYError:				invoke			MessageBox, NULL, offset InvYMSG, offset Program, MB_OK or MB_TASKMODAL or MB_ICONERROR															
						mov				eax, 1
						ret

OK:						invoke			EndDialog, DialogHandle, NULL
						mov				eax, 1

					.ELSEIF			(wParam == BUTTON_CANCEL)
						invoke			EndDialog, DialogHandle, NULL
						mov				eax, 1
					.ENDIF
				.ELSEIF			(Msg == WM_CLOSE)
					invoke			EndDialog, DialogHandle, NULL
					mov				eax, 1
				.ELSE
					mov				eax, 0
				.ENDIF
				ret
Dialog			endp					