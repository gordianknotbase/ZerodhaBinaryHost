@echo off
setlocal enabledelayedexpansion

set APP_DIR=C:\ZeroAuto
set TARGET_DIR=%APP_DIR%\target
set LOG_DIR=%APP_DIR%\logs
set TRANS_DIR=%APP_DIR%\transactions
set HOLD_DIR=%APP_DIR%\Holdings
set LATEST_VERSION_URL=https://raw.githubusercontent.com/gordianknotbase/ZerodhaBinaryHost/main/version.txt

:: Fetch latest version
echo [INFO] Fetching latest version from GitHub...
powershell -Command "(New-Object Net.WebClient).DownloadString('%LATEST_VERSION_URL%')" > "%TEMP%\remote_version.txt"
for /f "delims=" %%a in ('type "%TEMP%\remote_version.txt"') do set "LATEST_VERSION=%%a"

echo [INFO] Latest version = %LATEST_VERSION%


:: Detect local version from JAR filename
set "LOCAL_VERSION=none"
set "JAR_FOUND=false"
for %%f in ("%TARGET_DIR%\zerodhaautomation-*-SNAPSHOT.jar") do (
    set "FILENAME=%%~nf"  %%~nf gives name without extension
    set "FILENAME=!FILENAME:zerodhaautomation-=!"
    set "FILENAME=!FILENAME:-SNAPSHOT=!"
    set "LOCAL_VERSION=!FILENAME!"
    set "JAR_FOUND=true"
    goto :found_version
)

if /i "!JAR_FOUND!"=="false" (
    echo [DEBUG] No local JAR found in: %TARGET_DIR%
)
:found_version

echo [INFO] Local version = %LOCAL_VERSION%

:: Construct ZIP URL
set ZIP_URL=https://github.com/gordianknotbase/ZerodhaBinaryHost/releases/download/v%LATEST_VERSION%/ZerodhaSetup-v%LATEST_VERSION%.zip
set ZIP_FILE=%TEMP%\ZerodhaSetup-v%LATEST_VERSION%.zip

:: Compare versions
if "!LOCAL_VERSION!" NEQ "%LATEST_VERSION%" (
    echo [INFO] New version detected! Downloading ZIP...

    powershell -Command "(New-Object Net.WebClient).DownloadFile('%ZIP_URL%', '%ZIP_FILE%')"
	
	if not exist "%ZIP_FILE%" (
    echo [ERROR] Failed to download update
    exit /b 1
)

    echo [INFO] Cleaning old files...
    del /q "%TARGET_DIR%\*" >nul 2>&1
    rmdir /s /q "%TARGET_DIR%" >nul 2>&1

    echo [INFO] Extracting new setup...
    powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%APP_DIR%' -Force"
) else (
    echo [INFO] Already on the latest version.
)

:: Run the JAR
echo [INFO] Running equityHoldings...
"%APP_DIR%\sapmachine-jre-21.0.7\bin\java" -jar "%TARGET_DIR%\zerodhaautomation-%LATEST_VERSION%-SNAPSHOT.jar" equityHoldings

	echo [INFO] Cleaning.....
	del /q "%LOG_DIR%\*" >nul 2>&1
	rmdir /s /q "%LOG_DIR%" >nul 2>&1
	del /q "%TRANS_DIR%\*" >nul 2>&1
	rmdir /s /q "%TRANS_DIR%" >nul 2>&1
	del /q "%HOLD_DIR%\*" >nul 2>&1
	rmdir /s /q "%HOLD_DIR%" >nul 2>&1
	echo [INFO] Cleaning Done.....

endlocal