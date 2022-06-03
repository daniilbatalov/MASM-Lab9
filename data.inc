				include 		D:\masm32\include\windows.inc
				include 		D:\masm32\include\user32.inc
				include 		D:\masm32\include\kernel32.inc
				include 		D:\masm32\include\gdi32.inc

				includelib 		D:\masm32\lib\kernel32.lib
				includelib 		D:\masm32\lib\user32.lib
				includelib 		D:\masm32\lib\gdi32.lib

DrawGrid		proto			:HDC, :RECT, :POINT, :POINT, :POINT
DrawGraph		proto			:HDC, :POINT, :POINT, :POINT
Func			proto			:DWORD

				.data
ClassName		db				"Draw", 0
Program			db				"Lab9", 0
MenuName		db				"CMenu", 0
AboutMSG		db				"Lab9, Variant #1", 0DH, 0AH, "y = x^3 + 6x - 4", 0
InvXMSG			db				"Error! Invalid value of X!", 0
InvYMSG			db				"Error! Invalid value of Y!", 0

coord			struct
X_left			dd				?				
X_right			dd				?
Y_down			dd				?
Y_up			dd				?
coord			ends	

				.data?
Handle			HINSTANCE		?
CMD				LPSTR			?
bounds			coord			<?>

				.const
BUTTON_ABOUT	equ				1
BUTTON_SETTINGS	equ				2
BUTTON_EXIT		equ				3
WINDOW_SETTINGS	equ				1000
EDITBOX_X_LEFT	equ				1001
EDITBOX_X_RIGHT	equ				1002
EDITBOX_Y_DOWN	equ				1003
EDITBOX_Y_UP	equ				1004
BUTTON_OK		equ				1005
BUTTON_CANCEL	equ				1006

				include			windows.asm
				include			draw.asm					