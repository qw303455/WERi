@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

title windows安装程序

set "APP_NAME=MyApp 高级版"
set "DEFAULT_INSTALL_DIR=%USERPROFILE%\AppData\Local\%APP_NAME%"
set "INSTALL_DIR=%DEFAULT_INSTALL_DIR%"
set "SCRIPT_DIR=%~dp0"
set "SETUP_EXE=%SCRIPT_DIR%setup.exe"
set "SETUP_ADV_EXE=%SCRIPT_DIR%setup_advanced.exe"
set "SETUP_MSI=%SCRIPT_DIR%setup.msi"
set "DESKTOP_SHORTCUT=%USERPROFILE%\Desktop\%APP_NAME%.lnk"
set "spinner=|/-\"
set "steps=6"
set "UPGRADE=0"
set "ADVANCED=0"
set "BACKUP_DIR=%TEMP%\%APP_NAME%_backup_%RANDOM%"
set "INSTALLED_SETUP_NAME="
set "ARG_MODE=%~1"
set "stepName1=检测安装状态"
set "stepName2=检查管理员权限"
set "stepName3=创建安装目录"
set "stepName4=复制安装文件"
set "stepName5=运行安装程序"
set "stepName6=创建快捷方式"

if "%ARG_MODE%"=="" (
    echo 默认安装目录: %INSTALL_DIR%
    set /p "INPUT_INSTALL_DIR=输入安装目录，或直接回车使用默认目录: "
    if not "%INPUT_INSTALL_DIR%"=="" (
        set "INSTALL_DIR=%INPUT_INSTALL_DIR%"
    )
    echo 使用安装目录: %INSTALL_DIR%
)

cls
echo ==============================
echo     自动安装程序 权限©俊所有
echo ==============================
echo.
echo 正在自动安装，请勿关闭窗口...
echo.

for /L %%i in (1,1,%steps%) do call :runStep %%i

echo.
echo 安装完成！
echo 安装目录: %INSTALL_DIR%
if "%ADVANCED%"=="1" (
    echo 已成功安装高级版。
) else (
    echo 已成功安装标准版。
)
if "%UPGRADE%"=="1" echo 这是一次升级安装，旧版本已备份至 %BACKUP_DIR%
echo.
pause
exit /b

:checkAdmin
net session >nul 2>&1
if errorlevel 1 (
    echo 请以管理员身份运行此安装程序！
    pause
    exit /b 1
)
echo 已确认管理员权限。
call :animateAction "管理员权限" 8
exit /b

:runStep
set "step=%1"
call set "name=%%stepName%step%%%"
echo [步骤 %step%/%steps%] !name!...

if %step%==1 (
    if exist "%INSTALL_DIR%\*" (
        set "UPGRADE=1"
        echo 检测到旧版本安装，正在执行升级安装...
        if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"
        echo 备份旧版本文件到 %BACKUP_DIR% ...
        robocopy "%INSTALL_DIR%" "%BACKUP_DIR%" /E /NFL /NDL /NJH /NJS >nul
        if errorlevel 8 (
            echo 备份过程中发生错误，继续执行安装。
        ) else (
            echo 旧版本备份完成。
        )
    ) else (
        if /I "%ARG_MODE%"=="advanced" (
            echo 未检测到旧版本，执行高级版全新安装。
        ) else (
            echo 未检测到旧版本，执行标准版全新安装。
        )
    )
    if /I "%ARG_MODE%"=="advanced" (
        if exist "%SETUP_ADV_EXE%" (
            set "ADVANCED=1"
            echo 已指定高级版安装，使用高级版安装程序。
            set "SETUP_EXE=%SETUP_ADV_EXE%"
            set "INSTALLED_SETUP_NAME=setup_advanced.exe"
        ) else (
            echo 未找到高级版安装包，请将 setup_advanced.exe 放到脚本目录后重试。
            pause
            exit /b 1
        )
    ) else if exist "%SETUP_ADV_EXE%" (
        set "ADVANCED=1"
        echo 检测到高级版安装包，优先使用高级安装程序。
        set "SETUP_EXE=%SETUP_ADV_EXE%"
        set "INSTALLED_SETUP_NAME=setup_advanced.exe"
    ) else (
        set "INSTALLED_SETUP_NAME=setup.exe"
    )
)

if %step%==2 (
    call :checkAdmin
)

if %step%==3 (
    if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
    if errorlevel 1 (
        echo 创建安装目录失败。
        pause
        exit /b 1
    )
)

if %step%==4 (
    if exist "%SETUP_EXE%" (
        if "%INSTALLED_SETUP_NAME%"=="" for %%F in ("%SETUP_EXE%") do set "INSTALLED_SETUP_NAME=%%~nxF"
        copy /Y "%SETUP_EXE%" "%INSTALL_DIR%\%INSTALLED_SETUP_NAME%" >nul
        echo 已复制 %INSTALLED_SETUP_NAME%
        set "INSTALLED_SETUP=%INSTALL_DIR%\%INSTALLED_SETUP_NAME%"
    ) else if exist "%SETUP_MSI%" (
        copy /Y "%SETUP_MSI%" "%INSTALL_DIR%\" >nul
        echo 已复制 setup.msi
        set "INSTALLED_SETUP=%INSTALL_DIR%\setup.msi"
    ) else (
        echo 未找到 setup_advanced.exe、setup.exe 或 setup.msi，请将安装包放到脚本同后再运行。
        pause
        exit /b 1
    )
)

if %step%==5 (
    if defined INSTALLED_SETUP (
        if /I "%INSTALLED_SETUP:~-4%"==".exe" (
            echo 正在运行 setup.exe 安装...
            start /wait "" "%INSTALLED_SETUP%"
        ) else (
            echo 正在运行 MSI 安装...
            msiexec /i "%INSTALLED_SETUP%" /qb
        )
        if errorlevel 1 (
            echo 安装程序执行失败。
            pause
            exit /b 1
        )
    ) else (
        echo 安装文件不存在，跳过安装程序运行。
    )
)

if %step%==6 (
    if defined INSTALLED_SETUP (
        powershell -NoProfile -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%DESKTOP_SHORTCUT%'); $s.TargetPath = '%INSTALLED_SETUP%'; $s.WorkingDirectory = '%INSTALL_DIR%'; $s.Save()"
        if errorlevel 1 (
            echo 快捷方式创建失败。
        ) else (
            echo 已创建桌面快捷方式。
        )

        set "UNINSTALL_BATCH=%INSTALL_DIR%\uninstall.bat"
        set "UNINSTALL_REG=HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\%APP_NAME%"

        >"%UNINSTALL_BATCH%" echo @echo off
        >>"%UNINSTALL_BATCH%" echo echo 正在卸载 %APP_NAME%...
        >>"%UNINSTALL_BATCH%" echo cd /d %%TEMP%%
        >>"%UNINSTALL_BATCH%" echo start "" /wait powershell -NoProfile -Command "Remove-Item -LiteralPath '%INSTALL_DIR%' -Recurse -Force"
        >>"%UNINSTALL_BATCH%" echo reg delete "%UNINSTALL_REG%" /f ^>nul 2^>^&1
        >>"%UNINSTALL_BATCH%" echo echo 卸载完成。
        >>"%UNINSTALL_BATCH%" echo pause
        >>"%UNINSTALL_BATCH%" echo exit /b

        reg add "%UNINSTALL_REG%" /v "DisplayName" /d "%APP_NAME%" /f >nul
        reg add "%UNINSTALL_REG%" /v "UninstallString" /d "\"%UNINSTALL_BATCH%\"" /f >nul
        reg add "%UNINSTALL_REG%" /v "DisplayIcon" /d "\"%INSTALL_DIR%\%INSTALLED_SETUP_NAME%\"" /f >nul
        reg add "%UNINSTALL_REG%" /v "DisplayVersion" /d "1.0" /f >nul
        reg add "%UNINSTALL_REG%" /v "Publisher" /d "MyApp" /f >nul
        reg add "%UNINSTALL_REG%" /v "InstallLocation" /d "%INSTALL_DIR%" /f >nul
    ) else (
        echo 安装目录中未找到安装程序文件，快捷方式跳过。
    )
)

call :animateAction "!name!" 8
exit /b

:animateAction
set "label=%~1"
set /a count=%2
for /L %%j in (1,1,%count%) do (
    set /a idx=%%j %% 4
    if !idx! equ 0 set idx=4
    set "spin=!spinner:~!idx!,1!"
    <nul set /p="正在执行: !label! !spin!  "
    ping -n 2 127.0.0.1 >nul
)
echo.
exit /b
