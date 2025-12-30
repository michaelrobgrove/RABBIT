@echo off
title RABBIT IPTV Player - Installer
color 0A

echo.
echo  ====================================
echo   🐰 RABBIT IPTV Player - Installer
echo  ====================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed!
    echo.
    echo Please install Python from: https://python.org/downloads
    echo.
    echo IMPORTANT: Check "Add Python to PATH" during installation
    echo.
    pause
    exit /b 1
)

echo [✓] Python found
echo.

REM Create start script
echo Creating startup script...
(
echo @echo off
echo title RABBIT IPTV Player
echo color 0A
echo.
echo  ====================================
echo   🐰 RABBIT IPTV Player
echo  ====================================
echo.
echo  Starting server...
echo.
echo cd /d "%%~dp0"
echo.
echo echo  ✓ Python found
echo echo.
echo echo  Server running at:
echo echo  ┌────────────────────────────────┐
echo echo  │  http://localhost:8000         │
echo echo  └────────────────────────────────┘
echo echo.
echo echo  Open the URL above in your browser
echo echo  Press Ctrl+C to stop the server
echo echo.
echo.
echo python -m http.server 8000
echo.
echo pause
) > start-rabbit.bat

echo [✓] Created start-rabbit.bat
echo.

REM Create desktop shortcut script
echo Creating desktop shortcut script...
(
echo Set oWS = WScript.CreateObject("WScript.Shell"^)
echo sLinkFile = oWS.SpecialFolders("Desktop"^) ^& "\RABBIT IPTV.lnk"
echo Set oLink = oWS.CreateShortcut(sLinkFile^)
echo oLink.TargetPath = WScript.ScriptFullName.Replace(WScript.ScriptName, "start-rabbit.bat"^)
echo oLink.WorkingDirectory = WScript.ScriptFullName.Replace(WScript.ScriptName, ""^)
echo oLink.Description = "RABBIT IPTV Player - Local Server"
echo oLink.IconLocation = WScript.ScriptFullName.Replace(WScript.ScriptName, "images\rabbit.svg"^)
echo oLink.Save
) > create-shortcut.vbs

echo [✓] Created desktop shortcut script
echo.

REM Ask if user wants desktop shortcut
set /p SHORTCUT="Create desktop shortcut? (Y/N): "
if /i "%SHORTCUT%"=="Y" (
    cscript //nologo create-shortcut.vbs
    echo [✓] Desktop shortcut created!
)

echo.
echo  ====================================
echo   ✅ Installation Complete!
echo  ====================================
echo.
echo  To start RABBIT:
echo  1. Double-click "start-rabbit.bat"
echo  2. Open http://localhost:8000 in your browser
echo.
echo  Desktop shortcut: "RABBIT IPTV" on your desktop
echo.
echo  To uninstall: Just delete this folder
echo.

pause
