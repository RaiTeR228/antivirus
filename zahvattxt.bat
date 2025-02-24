@echo off
mode con cols=80 lines=20
color 0A

:: Укажите букву флешки (замените D: на свою)
set FLASH_DRIVE=C:\Users\RaiTer\Desktop\Generated_Files
set DESTINATION=%USERPROFILE%\Desktop\TXT_Files

:: Создание папки, если её нет
if not exist "%DESTINATION%" mkdir "%DESTINATION%"

:: Копирование файлов с максимальной скоростью
robocopy "%FLASH_DRIVE%" "%DESTINATION%" *.bat /e /mt:16 /r:0 /w:0 /ndl /njh /njs /np

exit