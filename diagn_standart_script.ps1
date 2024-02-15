##Проверить наличие и применение политики обновлений при помощи «Результирующей политики»
#написать проверку на наличие папки с:\avi

# Получаем текущую дату
$currentDate = Get-Date -Format "yyyy-MM-dd"

# Создаем путь к файлу с текущей датой в имени
$filePath = "C:\avi\diagnosik_month_$currentDate.txt"
New-Item -Path $filePath -ItemType File
$logfiletest = "c:\avi\diagnosik_month_$currentDate.txt"
$source_pol1 = "c:\avi\report.html"
GPResult /h c:\avi\report.html /f
#создать файл с результирующими политиками
$err=@()
$hash = @{
 'Включить рекомендуемые обновления через автоматическое обновление</span></td><td>Включено</td><td>Local Group Policy</td></tr>' = 'Включить рекомендуемые обновления через автоматическое обновление-Включено'
 #
 'Включить уведомления о наличии программ</span></td><td>Отключено</td><td>'='Включить уведомления о наличии программ – отключить.'
 #
 'Всегда автоматически перезагружаться в запланированное время</span></td><td>Включено</td><td>'='Всегда автоматически перезагружаться в запланированное время – включить '
 #
 #'Ждать в течение следующего промежутка времени,</td></tr><tr><td colspan="2">прежде чем выполнить запланированную</td></tr><tr><td>перезагрузку (в минутах):  </td><td>15'='Таймер перезагрузки дает пользователям указанное время на сохранение -15 минут'
 #
 'Настройка автоматического обновления</span></td><td>Включено</td><td>'='Настройка автоматического обновления – включить - '
 #
 'Настройка автоматического обновления:</td><td>4 — авт. загрузка и устан. по расписанию'='4-авт. Загрузка и устан. по расписанию – 0-ежедневно:'
 #
 'Установка по расписанию — день:  </td><td>0 — ежедневно'='Загрузка и устан. по расписанию -ежедневно'
 #
 'Установка по расписанию — время:</td><td>05:00'='Если сервер виртуальный – 5:00.'
 #
 'Установка по расписанию — время:</td><td>04:00'='Если сервер физический – 4:00.'
#
'Не выполнять автоматическую перезагрузку при автоматической установке обновлений, если в системе работают пользователи</span></td><td>Отключено'= 'Не выполнять автоматическую перезагрузку при автоматической установке обновлений, если в системе работают пользователи – отключить.'
#
'Не задавать по умолчанию параметр &#171;Установить обновления и завершить работу&#187; в диалоговом окне &#171;Завершение работы Windows&#187;</span></td><td>Включено'= 'Не задавать по умолчанию параметр «Установить обновления и завершить работу»… - включить.'
#
'Не отображать параметр &#171;Установить обновления и завершить работу&#187; в диалоговом окне &#171;Завершение работы Windows&#187;</span></td><td>Включено'= 'Не отображать параметр «Установить обновления и завершить работу»… - включить.'
#
'Разрешать пользователям, не являющимся администраторами, получать уведомления об обновлениях</span></td><td>Отключено'= 'Разрешать пользователям, не являющимся администраторами, получать уведомление… - отключить.'
#
'Разрешить немедленную установку автоматических обновлений</span></td><td>Включено'= 'Разрешить немедленную установку автоматических обновлений – включить.'
#
'Разрешить прием обновлений с подписью из службы обновления Майкрософт в интрасети  </span></td><td>Включено'= 'Разрешить прием обновлений с подписью из службы обновления Майкрософт в интрасети – включить.'
#
'Разрешить управлению электропитанием центра обновления Windows выводить систему из спящего режима для установки запланированных обновлений</span></td><td>Включено'='Разрешить управлению электропитанием центра обновления Windows выводить систему их спящего режима… - включить.'
}
#Select-String -Pattern l1 -Path $source_pol1 -SimpleMatch 
New-Item $logfiletest ItemType File -ErrorAction SilentlyContinue| Out-Null
foreach ($h in $hash.GetEnumerator())

{
if (Select-String -Pattern $($h.Name) -Path $source_pol1  ) {add-Content -Path $logfiletest -Value "$($h.Value)"} 
                                else {add-Content -Path $logfiletest -Value  "ВНИМАНИЕ ОШИБКА! $($h.Value)" }}
                                
                                
                                #удаление файла связано с безопасностью
                                
                                Remove-Item –path "$source_pol1" 
                                
                                #Проверка политики паролей

$hash2 = @{

'MinimumPasswordLength = 8' = 'Минимальная длина пароля – 8 символов'
'PasswordComplexity = 1' = 'Пароль должен отвечать требованиям сложности – Да.'
'ClearTextPassword = 1' = 'Хранить пароли, используя обратимое шифрование – Да.'
'LockoutDuration = 15' = 'Время до сброса счетчика блокировки  - 15 мин.'
'LockoutBadCount = 3' = 'Пороговое значение блокировки – 3 попытки.'
'ResetLockoutCount = 15' = 'Продолжительность блокировки – 15 мин.'
}
$source_secu = "C:\avi\secpol.cfg"
secedit /export /cfg C:\avi\secpol.cfg /areas securitypolicy

foreach ($h2 in $hash2.GetEnumerator())

{
if (Select-String -Pattern $($h2.Name) -Path $source_secu  ) {add-Content -Path $logfiletest -Value "$($h2.Value)"} 
                                else {add-Content -Path $logfiletest -Value  "ВНИМАНИЕ ОШИБКА! $($h2.Value)" }}

#удаление файла связано с безопасностью
                                Remove-Item –path "$source_secu" 
                                
                                #Определяет уникальных пользователей под которыми работают службы
                                Add-Content -Path $logfiletest -Value "пользователи служб"
                                Get-WmiObject win32_service |Format-List startName|Out-String -Stream |Sort-Object -Unique|Add-Content -Path  $logfiletest
                                

#Проверить правильность именования администраторов сервера и домена
Add-Content -Path $logfiletest -Value "Администраторы"
Get-LocalGroupMember -Group "Администраторы"-ErrorAction SilentlyContinue |select Name |Add-Content -Path $logfiletest
Get-ADGroupMember -Identity "Администраторы" -ErrorAction SilentlyContinue |select name  |Add-Content -Path $logfiletest

#Проверить настройку теневых копий только время последних копий
Add-Content -Path $logfiletest -Value "Время записи последних теневых копий"
Get-CimInstance -ClassName Win32_ShadowCopy | Select-Object -Property InstallDate|Add-Content -Path $logfiletest

#Для серверов с ролью IIS проверить наличие запланированного задания 
$roleIIS = @(Get-WindowsFeature -Name web-* | Where installed)
if ($roleIIS.Count > 0) 
{$IIS_rol = (Get-ScheduledTask -Taskname "*IIS")|Add-Content -Path $logfiletest -value $IIS_rol[-1]} 
else {Add-Content -Path $logfiletest -Value "нет IIS "} 

# проверка мини дампа

# Получить текущее значение CrashDumpEnabled
$crashDumpEnabled = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\CrashControl' -Name 'CrashDumpEnabled').CrashDumpEnabled

# Проверить значение и вывести соответствующее сообщение
if ($crashDumpEnabled -eq 3) {
    Write-Host "Малый дамп включен."
} else {
    Write-Host "Малый дамп выключен или имеет другое значение."
}
Start-Process "C:\avi\diagnosik_month_$currentDate.txt"

Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -IgnoreReboot 

# проверка на драйвера
Get-WmiObject -Class Win32_PnpEntity -ComputerName localhost -Namespace Root\CIMV2 | Where-Object {$_.ConfigManagerErrorCode -gt 0 } | select Name, DeviceID, ConfigManagerErrorCode| ft

$taskName = "RebootTask"

# Попытка удалить существующее задание с таким же именем
Unregister-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

$action = New-ScheduledTaskAction -Execute "shutdown" -Argument "/r /f /t 0"
$triggerDate = (Get-Date).AddDays(1).Date
$trigger = New-ScheduledTaskTrigger -Once -At $triggerDate.Date.AddHours(5)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Description "Scheduled reboot task for tomorrow"
