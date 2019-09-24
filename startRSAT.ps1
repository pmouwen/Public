$CurrentID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$CurrentPrincipal = new-object System.Security.Principal.WindowsPrincipal($CurrentID)
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
$LogDir = "C:\RSAT\ARCHIVE"
$folder = 'C:\RSAT\IN'
$filter = '*.rsat'
$destination = 'C:\RSAT\ARCHIVE'
$LogDirTmp = 'C:\RSAT\ROLLING_LOG\'
$RSATPath = "C:\Program Files (x86)\Regression Suite Automation Tool\"
$RSATApp = "Microsoft.Dynamics.RegressionSuite.ConsoleApp.exe"

function Get-TimeStamp {
    
    return "[{0:MM/dd/yy} {0:HH:mm:ss}]" -f (Get-Date)
    
}

$fsw = New-Object IO.FileSystemWatcher $folder, $filter -Property @{
 IncludeSubdirectories = $false            
 NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'
}

$onCreated = Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
 $path = $Event.SourceEventArgs.FullPath
 $name = $Event.SourceEventArgs.Name
 $changeType = $Event.SourceEventArgs.ChangeType
 $timeStamp = $Event.TimeGenerated
 
 #Get file content
 $TestCase = Get-Content -Path $path -TotalCount 1

 #Move file to destination:
 Move-Item $path -Destination $destination -Force -Verbose

 $LogFile = $LogDirTmp + $name + ".log"

 #Log if running with elevated permissions:
if ($CurrentPrincipal.IsInRole($adminRole)) {
    Write-Output "User session: ELEVATED" | Out-file $LogFile -append
}else{
    Write-Output "User session: NORMAL" | Out-file $LogFile -append
}

 #Write to log file:
 Write-Output "1. $(Get-TimeStamp) Test case #: $TestCase" | Out-file $LogFile -append
 Write-Output "2. $(Get-TimeStamp) File $name Archived to: $destination" | Out-file $LogFile -append
 Write-Output "3. $(Get-TimeStamp) Starting RSAT execution" | Out-file $LogFile -append


 #Start RSAT:
$RSATResultFile = $LogDir + "\" + $name + "_Result" + ".log"
$cmdPath = $RSATPath + $RSATApp
$cmdArgList = @(
	"playbackbyid",
    $TestCase)

Write-Output "4. $(Get-TimeStamp) Starting logging" | Out-file $LogFile -append

#& $cmdPath $cmdArgLis
& $cmdPath $cmdArgList > $RSATResultFile

Write-Output "5. $(Get-TimeStamp) Ending logging" | Out-file $LogFile -append
Move-Item $LogFile -Destination $LogDir -Force -Verbose
} 
 

while ($true) {sleep 1}

# Unregister-Event FileCreated 