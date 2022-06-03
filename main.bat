ml /c /coff main.asm
rc /r cresource.rc
link /subsystem:windows main.obj cresource.res
pause