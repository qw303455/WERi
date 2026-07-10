[Version]
Class=IEXPRESS
SEDVersion=3

[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=1
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=正在准备安装，请稍候...
DisplayLicense=0
FinishMessage=安装包已准备好。
TargetName=setup.exe
FriendlyName=MyApp 高级版 安装程序
AppLaunched=windows.bat
PostInstallCmd=%COMSPEC% /c windows.bat

[Files]
File0="C:\Users\qw303\Desktop\安装\windows.bat"
