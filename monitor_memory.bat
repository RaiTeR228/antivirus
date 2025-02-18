@echo off
setlocal enabledelayedexpansion

rem Установка порога памяти (2 ГБ в килобайтах)
set "MEMORY_THRESHOLD=2097152"

rem Лог-файл
set "LOG_FILE=monitor.log"

rem Запись начала мониторинга в лог
echo [%date% %time%] Monitoring started >> "%LOG_FILE%"

rem Получаем список процессов и их использование памяти
for /f "skip=3 tokens=1,2 delims=," %%a in ('tasklist /fo csv') do (
    set "PROCESS_NAME=%%a"
    set "PROCESS_ID=%%b"
    
    rem Удаляем кавычки из имени процесса и PID
    set "PROCESS_NAME=!PROCESS_NAME:~1,-1!"
    set "PROCESS_ID=!PROCESS_ID:~1,-1!"

    rem Получаем использование памяти для процесса
    for /f "tokens=5 delims= " %%m in ('tasklist /fi "PID eq !PROCESS_ID!" /fo table') do (
        set "PROCESS_MEMORY=%%m"
        rem Удаляем "K" из значения памяти
        set "PROCESS_MEMORY=!PROCESS_MEMORY:~0,-1!"

        rem Проверяем, превышает ли использование памяти порог
        if !PROCESS_MEMORY! gtr !MEMORY_THRESHOLD! (
            echo [%date% %time%] Process !PROCESS_NAME! (PID: !PROCESS_ID!) is using !PROCESS_MEMORY! KB of memory >> "%LOG_FILE%"
            echo Closing process !PROCESS_NAME! (PID: !PROCESS_ID!)...
            taskkill /F /PID !PROCESS_ID!
        )
    )
)

rem Запись окончания мониторинга в лог
echo [%date% %time%] Monitoring finished >> "%LOG_FILE%"
endlocal
pause