			.486
			.model			flat, stdcall
			option			casemap:none

			include			data.inc

			.code

begin:		mov				bounds.X_left, -10
			mov				bounds.X_right, 10
			mov				bounds.Y_down, -10
			mov				bounds.Y_up, 10

			invoke			GetModuleHandle, NULL
			mov				Handle, eax

			invoke			GetCommandLine
			mov				CMD, eax

			invoke			MainWindow, Handle, NULL, CMD, SW_SHOWNORMAL
			invoke			ExitProcess, eax

			end				begin