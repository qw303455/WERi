@echo off
setlocal enabledelayedexpansion

rem 获取回车符用于单行刷新
for /F %%A in ('copy /Z "%~dpf0" nul') do set "CR=%%A"

rem 进度条宽度
set total=40

rem 模拟安装步骤，请替换为实际命令
set steps=4
set stepNames[1]=准备文件
set stepNames[2]=复制文件
set stepNames[3]=配置环境
set stepNames[4]=完成清理

echo 正在安装，请稍候...
echo 准备文件...
for /L %%i in (1,1,%steps%) do call :runStep %%i
echo.
echo 安装完成！
pause
exit /b

:runStep
set step=%1
set name=!stepNames[%step%]!
set /a start=(step-1)*total/steps+1
set /a end=step*total/steps

for /L %%j in (!start!,1,!end!) do (
    set /a percent=%%j*100/%total%
    set "bar="
    for /L %%k in (1,1,%%j) do set "bar=!bar!>"
    set "spaces="
    for /L %%k in (1,1,%total%-%%j) do set "spaces=!spaces! "
    <nul set /p=安装中: [!bar!!spaces!] !percent!%% ^| !name!!CR!
    rem 这里用 ping 模拟安装进度，实际安装命令请替换为下面一行
    ping -n 2 127.0.0.1 >nul
)
exit /b
