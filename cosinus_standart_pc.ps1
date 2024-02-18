$userName = "TEIM"
$wshell = New-Object -ComObject Wscript.Shell
if (-not (Get-LocalUser $userName -ErrorAction SilentlyContinue))
{
    #Jeśli nie ma , zostanie utworzony
    $pass = Read-Host "Input new password for $userName" -AsSecureString
    New-LocalUser -Name $userName -Password $pass -UserMayNotChangePassword -PasswordNeverExpires
}


$Account = Get-LocalUser $userName

#Włącz swoje konto, jeśli jest wyłączone
if (-not $Account.Enabled) { Enable-LocalUser $Account }

#Jeśli konto nie należy do grupy Administratorzy, dodaj
if (-not (Get-LocalGroupMember -Member $Account -SID S-1-5-32-544 -ErrorAction SilentlyContinue ))
{
    Add-LocalGroupMember -SID S-1-5-32-544 -Member $Account
}

#Ustaw parametry "Uniemożliwij użytkownikowi zmianę hasła" i "Hasło nie wygasa"
Set-LocalUser $Account -PasswordNeverExpires $true -UserMayChangePassword $false 
net user TEIM cosinus123456

$ServiceManager = (New-Object -com "Microsoft.Update.ServiceManager")
$ServiceManager.Services
$ServiceID = "7971f918-a847-4430-9279-4a52d1efe18d"
$ServiceManager.AddService2($ServiceId,7,"")
$Output = $wshell.Popup("Wyłączanie szybkiego startu",10)

#Punkt odzyskiwania
$Output = $wshell.Popup("Tworzenie punktu przywracania",10)
Enable-ComputerRestore -Drive “C:\”

Checkpoint-Computer -Description “MyRestorePoint” -RestorePointType “MODIFY_SETTINGS”
Get-ComputerRestorePoint | Format-Table -AutoSize
#Rozmiar dysku, który może być używany dla punktów odzyskiwania  
vssadmin resize shadowstorage /on=c: /for=c: /maxsize=10%
$Output = $wshell.Popup("Update Windows",10)
#zakaz update windows 10 windows 11
#if(!(Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate')){New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'}
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name TargetReleaseVersion -value '00000001' -Type DWord –Force
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name "ProductVersion" -value 'Windows 10' -Type String -Force
#Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name TargetReleaseVersionInfo -value '21H2' -Type String -Force
#https://apps.microsoft.com/detail/9NBLGGH4NNS1?hl=en-us&gl=US#activetab=pivot:overviewtab
# actualizacia windows

Install-Module -Name PSWindowsUpdate 
Get-Package -Name PSWindowsUpdate
Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot

Invoke-WebRequest -Uri "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -OutFile "$env:TEMP\winget.msixbundle"
Add-AppxPackage -Path "$env:TEMP\winget.msixbundle"
winget --version

winget upgrade Microsoft.AppInstaller
winget source update

winget install NoMachine.NoMachine --accept-package-agreements --silent ; 
winget install Oracle.VirtualBox  --accept-package-agreements --silent;
winget install Mikrotik.Winbox --accept-package-agreements --silent; 
winget install ApacheFriends.Xampp.8.2 --accept-package-agreements --silent;
winget install Microsoft.VisualStudioCode --accept-package-agreements --silent;
winget install Famatech.AdvancedIPScanner --accept-package-agreements --silent;
