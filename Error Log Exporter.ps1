#
#  This script exports consolidated and filtered event logs to CSV
#  
#
Write-Host Getting Computer Name
$Hostname = Hostname
Write-Host Validating Directory
$DOCDIR = [Environment]::GetFolderPath("CommonApplicationData") #locate path for output directory
$TARGETDIR = "$DOCDIR\Logs\"  #Set path for file output
$recordDays = Read-Host -Prompt "How many days would you like to record?" #Prompt user for how many days of logs
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
Set-Variable -Name EventAgeDays -Value $recordDays #we will take events for the latest x amount of days
Set-Variable -Name LogNames -Value @("Application", "System")  # Checking app and system logs
Set-Variable -Name EventTypes -Value @("Error")  # Loading only Errors and Warnings

$el_c = @()   #consolidated error log
$now=get-date
$startdate=$now.adddays(-$EventAgeDays)
$ExportFile=$TARGETDIR + "EVENTLOG" + $now.ToString("yyyy-MM-dd---hh-mm-ss") + ".csv"  # we cannot use standard delimiteds like ":"

foreach($log in $LogNames)
{
  Write-Host Processing $Hostname\$log
  $el = get-eventlog -ComputerName $Hostname -log $log -After $startdate -EntryType $EventTypes
  $el_c += $el  #consolidating
 }
$el_sorted = $el_c | Sort-Object TimeGenerated    #sort by time
Write-Host Exporting to $ExportFile
$el_sorted|Select EntryType, TimeGenerated, Source, EventID, Message, MachineName | Export-CSV $ExportFile -NoTypeInfo  #EXPORT
Write-Host Done!
Invoke-Item $TARGETDIR
Read-Host -Prompt "Press Enter to exit"
