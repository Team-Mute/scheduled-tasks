@echo off
chcp 65001 > nul

:: 환경 변수 불러오기
call "%~dp0env.bat"

rem PostgreSQL 서버가 실행 중인지 확인하고, 실행 중이 아니면 시작합니다.
echo PostgreSQL 서버 상태를 확인합니다...
%PG_BIN%\pg_ctl.exe -D %PG_DATA% status > NUL 2>&1
if errorlevel 1 (
    echo.
    echo PostgreSQL 서버가 실행 중이 아닙니다. 서버를 시작합니다...
    %PG_BIN%\pg_ctl.exe -D %PG_DATA% start -l %BATCH_DIR%\pg_startup.log
    timeout /t 5 > NUL
    %PG_BIN%\pg_ctl.exe -D %PG_DATA% status > NUL 2>&1
    if errorlevel 1 (
        echo.
        echo 오류: PostgreSQL 서버 시작에 실패했습니다. 작업을 종료합니다.
        pause
        goto :eof
    )
    echo 서버 시작 완료.
) else (
    echo 서버가 이미 실행 중입니다.
)
echo.

rem SQL 쿼리를 실행하여 예약 상태를 업데이트합니다.
echo SQL 쿼리를 실행합니다...
set PGPASSWORD=%DB_PASSWORD%
%PG_BIN%\psql.exe -h %DB_IP% -U %DB_USER% -d %DB_NAME% -v ON_ERROR_STOP=1 -c "SET client_encoding TO 'UTF8';" -f %BATCH_DIR%\update_reservations_completed.sql

if errorlevel 1 (
    echo.
    echo 오류: SQL 쿼리 실행에 실패했습니다.
) else (
    echo.
    echo 예약 상태 업데이트가 완료되었습니다.
)

pause