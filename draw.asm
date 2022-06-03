				.data

strBuffer		db			256 dup (0)
strFormat		db			"%d"
strLen			dd			?
strX			db			"X"
strY			db			"Y"				

				.code

DrawGrid		proc		hdc:HDC, draw_rect:RECT, center:POINT, step:POINT, cnt:POINT

				local		thick_pen:HPEN
				local		thin_pen:HPEN
				local		x:DWORD
				local		y:DWORD
				local		count:DWORD
				local		num:DWORD

				invoke		CreatePen, PS_SOLID, 2, 0
				mov			thick_pen, eax

				invoke		CreatePen, PS_SOLID, 0, 0
				mov			thin_pen, eax

				invoke		SelectObject, hdc, thick_pen

				invoke		MoveToEx, hdc, center.x, 0, NULL
				invoke		LineTo, hdc, center.x, draw_rect.bottom
				invoke		MoveToEx, hdc, 0, center.y, NULL
				invoke		LineTo, hdc, draw_rect.right, center.y

				invoke		SelectObject, hdc, thin_pen
				invoke		SetTextAlign, hdc, TA_TOP or TA_CENTER

				xor			eax, eax
				mov			x, eax
				mov			eax, center.y
				mov			ebx, 3
				sub			eax, ebx
				mov			y, eax

				mov			eax, bounds.X_left
				mov			num, eax

				mov			ecx, cnt.x
				inc			ecx

x_strokes:		push		ecx
				invoke		MoveToEx, hdc, x, y, NULL
				mov			eax, y
				mov			ebx, 6
				add			eax, ebx
				mov			y, eax
				invoke		LineTo, hdc, x, y

				invoke		wsprintfA, ADDR strBuffer, ADDR strFormat, num
				dec			eax
				mov			strLen, eax
				invoke		TextOut, hdc, x, y, offset strBuffer, strLen

				mov			eax, x
				mov			ebx, step.x
				add			eax, ebx
				mov			x, eax
				mov			eax, y
				mov			ebx, 6
				sub			eax, ebx
				mov			y, eax
				inc			num
				pop			ecx
				loop		x_strokes

				mov			eax, y
				mov			ebx, 15
				add			eax, ebx
				mov			y, eax
				mov			eax, x
				mov			ebx, 10
				sub			eax, ebx
				mov			x, eax
				invoke		MoveToEx, hdc, x, y, NULL
				invoke		TextOut, hdc, x, y, offset strX, sizeof strX


				xor			eax, eax
				mov			y, eax
				mov			eax, center.x
				mov			ebx, 3
				sub			eax, ebx
				mov			x, eax

				mov			eax, bounds.Y_up
				mov			num, eax

				mov			eax, x
				mov			ebx, 25
				sub			eax, ebx
				mov			x, eax
				invoke		MoveToEx, hdc, x, y, NULL
				invoke		TextOut, hdc, x, y, offset strY, sizeof strY

				xor			eax, eax
				mov			y, eax
				mov			eax, center.x
				mov			ebx, 3
				sub			eax, ebx
				mov			x, eax

				mov			eax, bounds.Y_up
				mov			num, eax

				mov			ecx, cnt.y
				inc			ecx

y_strokes:		push		ecx
				invoke		MoveToEx, hdc, x, y, NULL
				mov			eax, x
				mov			ebx, 6
				add			eax, ebx
				mov			x, eax
				invoke		LineTo, hdc, x, y
				mov			eax, x
				mov			ebx, 8
				add			eax, ebx
				mov			x, eax

				mov			eax, y
				mov			ebx, 8
				sub			eax, ebx
				mov			y, eax

				cmp			num, 0
				je			aux_j

				invoke		wsprintfA, ADDR strBuffer, ADDR strFormat, num
				dec			eax
				mov			strLen, eax
				invoke		TextOut, hdc, x, y, offset strBuffer, strLen
				jmp			aux_j

aux_l:			jmp			y_strokes				

aux_j:			mov			eax, y
				mov			ebx, 8
				add			eax, ebx
				mov			ebx, step.y
				add			eax, ebx
				mov			y, eax
				mov			eax, x
				mov			ebx, 14
				sub			eax, ebx
				mov			x, eax
				dec			num
				pop			ecx
				loop		aux_l


				ret
DrawGrid		endp

DrawGraph		proc		hdc:HDC, center:POINT, step:POINT, cnt:POINT
				
				local		graph_pen:HPEN
				local		previous_dot_real:POINT
				local		previous_dot_value_x:DWORD
				local		previous_dot_value_y:DWORD
				local		current_dot_real:POINT
				local		current_dot_value_x:DWORD
				local		current_dot_value_y:DWORD

				invoke		CreatePen, PS_SOLID, 3, 0B0000Fh
				mov			graph_pen, eax
				invoke		SelectObject, hdc, graph_pen

				mov			eax, bounds.X_left
				mov			previous_dot_value_x, eax

				mov			previous_dot_real.x, 0

				invoke		Func, previous_dot_value_x
				mov			previous_dot_value_y, eax

				mov			ebx, eax
				mov			eax, bounds.Y_up
				sub			eax, ebx
				mov			ebx, step.y
				mul			ebx
				mov			previous_dot_real.y, eax


				invoke		MoveToEx, hdc, previous_dot_real.x, previous_dot_real.y, NULL
				mov			ecx, cnt.x
gr:				push		ecx

				mov			eax, previous_dot_real.x
				mov			ebx, step.x
				add			eax, ebx
				mov			current_dot_real.x, eax

				mov			eax, previous_dot_value_x
				inc			eax
				mov			current_dot_value_x, eax

				invoke		Func, current_dot_value_x
				mov			current_dot_value_y, eax

				mov			ebx, eax
				mov			eax, bounds.Y_up
				sub			eax, ebx
				mov			ebx, step.y
				mul			ebx
				mov			current_dot_real.y, eax

				invoke		LineTo, hdc, current_dot_real.x, current_dot_real.y

				mov			eax, current_dot_real.x
				mov			previous_dot_real.x, eax

				mov			eax, current_dot_real.y
				mov			previous_dot_real.y, eax

				mov			eax, current_dot_value_x
				mov			previous_dot_value_x, eax

				mov			eax, current_dot_value_y
				mov			previous_dot_value_y, eax

				invoke		MoveToEx, hdc, previous_dot_real.x, previous_dot_real.y, NULL
				

				pop			ecx
				loop		gr
				ret
DrawGraph		endp

Func			proc		x:DWORD				
				mov			eax, x
				imul		x
				imul		x
				push		eax

				mov			eax, x
				mov			ebx, 6
				imul		ebx
				pop			ebx

				add			eax, ebx
				mov			ebx, 4
				sub			eax, ebx

				ret
Func			endp				






