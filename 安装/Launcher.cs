using System;
using System.Diagnostics;
using System.IO;

class Program
{
    const string BatchScript = @"@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

title windows安装程序

set ""APP_NAME=MyApp 高级版""
set ""INSTALL_DIR=%USERPROFILE%
ppData
ata
ppData
ppData
ppData
ppData
ppData
ppData
ppData
u";

    static int Main(string[] args)
    {
        Console.WriteLine("MyApp 高级版安装程序");
        Console.WriteLine("正在准备安装，请稍候...");

        string tempDir = Path.Combine(Path.GetTempPath(), "MyAppInstaller");
        Directory.CreateDirectory(tempDir);

        string scriptPath = Path.Combine(tempDir, "windows_installer.bat");
        File.WriteAllText(scriptPath, BatchScript);

        ProcessStartInfo psi = new ProcessStartInfo();
        psi.FileName = "cmd.exe";
        psi.Arguments = "/d /c \"\"" + scriptPath + "\"\"";
        psi.WorkingDirectory = tempDir;
        psi.UseShellExecute = true;
        psi.Verb = "runas";

        try
        {
            Process.Start(psi);
            return 0;
        }
        catch (Exception ex)
        {
            Console.WriteLine(ex.Message);
            return 1;
        }
    }
}
