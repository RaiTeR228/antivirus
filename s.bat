@echo off
setlocal enabledelayedexpansion

set LOG_FILE=monitor.log
set CPU=20
set "SUSPICIOUS=C:\Temp;C:\Users\Public;C:\Program Files;C:\Users\DaYaRusskiy\Desktop\WindowsNoEditor"
set "MALICIOUS_PROCESSES=malware.exe;VotV-Win64-Shipping.exe"

echo Starting process monitoring...
echo.

:monitor_loop
for /f "skip=1 tokens=1-4 delims=, " %%a in ('wmic path Win32_Process get Name,ProcessId,ExecutablePath,CommandLine /format:csv ^| findstr /v "^$"') do (
    set "process_name=%%a"
    set "process_id=%%b"
    set "process_path=%%c"
    set "command_line=%%d"

    if "!process_path!"=="" (
        set "process_path=N/A"
    )

    rem Получаем использование CPU для текущего процесса
    set "cpu_usage="
    for /f "tokens=2 delims==" %%x in ('wmic path Win32_PerfFormattedData_PerfProc_Process where "IDProcess=%%b" get PercentProcessorTime /value') do (
        set "cpu_usage=%%x"
    )

    rem Отладочный вывод для CPU
    echo Debug: Process !process_name! (PID: !process_id!) has CPU usage: !cpu_usage!

    rem Проверяем, что cpu_usage установлен и больше или равен порогу
    if defined cpu_usage (
        set /a cpu_usage_int=!cpu_usage!
        if !cpu_usage_int! gtr !CPU! (
            set "log_message=High CPU usage: Process !process_name! (PID: !process_id!) using !cpu_usage!%%, Command Line: !command_line!"
            echo !log_message!
            call :log "!log_message!"
            call :block_process !process_id! "High CPU usage"
        )
    )

    rem Проверка на подозрительные процессы
    for %%i in (%SUSPICIOUS%) do (
        if "!process_path:~0,%len(%%i)!"=="%%i" (
            set "log_message=Suspicious process: !process_name! (PID: !process_id!) located in: !process_path!, Command Line: !command_line!"
            echo !log_message!
            call :log "!log_message!"
            call :block_process !process_id! "Suspicious location"
            goto :next_process
        )
    )

    rem Проверка на вредоносные процессы
    for %%m in (%MALICIOUS_PROCESSES%) do (
        if /i "!process_name!"=="%%m" (
            set "log_message=Malicious process detected: !process_name! (PID: !process_id!), Command Line: !command_line!"
            echo !log_message!
            call :log "!log_message!"
            call :block_process !process_id! "Malicious process detected"
            goto :next_process
        )
    )

    :next_process
)
timeout /t 5 /nobreak >nul
goto :monitor_loop

:log
echo [%date% %time%] %~1 >> "%LOG_FILE%"
goto :eof

:block_process
echo [%date% %time%] Attempting to terminate process %~1 (%~2)...
TASKKILL /F /PID %~1 2>nul
if errorlevel 1 (
    echo [%date% %time%] Failed to terminate process %~1. Error code: !errorlevel!
) else (
    echo [%date% %time%] Process %~1 terminated.
)
goto :eof
