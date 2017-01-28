#
#  This script exports consolidated and filtered event logs to CSV
#  
#
Write-Host Getting Computer Name
$Hostname = Hostname
Write-Host Validating Directory
$DOCDIR = [Environment]::GetFolderPath("CommonApplicationData")
$TARGETDIR = "$DOCDIR\Breeze Logs\"
if(!(Test-Path -Path $TARGETDIR )){
    New-Item -ItemType directory -Path $TARGETDIR
}
Set-Variable -Name EventAgeDays -Value 30     #we will take events for the latest 7 days
#Set-Variable -Name CompArr -Value @("USBBCNU343CM31")   # replace it with your server names
Set-Variable -Name LogNames -Value @("Application", "System")  # Checking app and system logs
Set-Variable -Name EventTypes -Value @("Error")  # Loading only Errors and Warnings
#Set-Variable -Name ExportFolder -Value "$TARGETDIR"


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