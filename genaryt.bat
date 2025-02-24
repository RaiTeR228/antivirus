@echo off
title Генерация 10 000 файлов (20 КБ)
mode con cols=80 lines=20
color 0A

:: Папка, куда будут создаваться файлы
set OUTPUT_FOLDER=%USERPROFILE%\Desktop\Generated_Files

:: Количество файлов
set COUNT=10000

:: Размер файла в байтах (20 КБ = 20480 байт)
set SIZE=20480

echo ==============================
echo Создание %COUNT% файлов по 20 КБ...
echo ==============================

:: Создаём папку, если её нет
if not exist "%OUTPUT_FOLDER%" mkdir "%OUTPUT_FOLDER%"

:: Цикл генерации файлов
for /L %%i in (1,1,%COUNT%) do (
    fsutil file createnew "%OUTPUT_FOLDER%\file%%i.txt" %SIZE%
)

echo ==============================
echo Создание завершено!
echo ==============================
pause
exit
