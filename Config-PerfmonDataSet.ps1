<#
    .SYSNOPSIS
        Create Perfmon Data Collector Set.

    .LINKS
        https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/taming-perfmon-data-collector-sets/ba-p/255521

        Processor Counters - https://bobcares.com/blog/perfmon-counters-for-cpu-usage/
        Memory Counters - https://bobcares.com/blog/perfmon-counters-for-memory-usage/
        IIS Counters - https://techcommunity.microsoft.com/t5/iis-support-blog/performance-counters-for-monitoring-iis/ba-p/683389
#>

[CmdletBinding()]
Param (
    [String]$DataCollectorName = "IIS Server Stats",

    [String]$CountersFile = "$PSScriptRoot\Counters.json",

    [String]$RootPath = "L:\PerfMon"
)

# ----- . Source needed functions
. $PSScriptRoot\Functions\Get-PerfMonDataCollectorSet.ps1

# ----- . Source needed functions
. $PSScriptRoot\Functions\Get-PerfMonDataCollectorSet.ps1

# ----- Does the Set already exist?
$DataCollectorSet = Get-PerfMonDataCollectorSet -DataCollectorSetName $DataCollectorName

# ----- Create if it does not
if ( -Not $DataCollectorSet ) {
    Write-Verbose "Creating Data Collector Set -> $DataCollectorName"

    # ----- Create a new DataCollectorSet object.
    $NewSet = New-Object -COM Pla.DataCollectorSet
  
    # ----- Define Collector Set
    $NewSet.DisplayName = $DataCollectorName
    $NewSet.RootPath = $RootPath
    
    # ----- Define Collector
    $collector = $NewSet.DataCollectors.CreateDataCollector(0) 
    $collector.FileName              = $DataCollectorName + "_"
    $collector.FileNameFormat        = 0x1 
    $collector.FileNameFormatPattern = "yyyyMMdd"
    $collector.SampleInterval        = 3   # Collect data every 3s.
    $collector.LogAppend             = $true
  
    $Counters = Get-Content -Path $CountersFile | ConvertFrom-JSON
  
    $collector.PerformanceCounters   = $Counters
  
    # ----- Do we need to change the datamanager settings to save to cab from 1 to 2 days?
  
  
    # ----- Save the Collector Set
    try {
        $NewSet.DataCollectors.Add($collector) 
  
        Write-Verbose "DS = $($NewSet | out-string )"

        $NewSet.Commit("$DataCollectorName" , $null , 0x0003) | Out-Null
    }
    catch [Exception] { 
        $EXceptionMessage = $_.Exception.Message
        $ExceptionType = $_.exception.GetType().fullname
        Throw "Config-PerfmonDataSet : Exception Caught:`n`n     $ExceptionMessage`n`n     Exception : $ExceptionType" 
    }
}
Else {
    Write-Verbose "DS Exists"
    Write-Verbose "$($DataCollectorSet | Out-string)"
}

# ----- Now lets look at the scheduled task and make sure it is set corrrectly
$Task = Get-ScheduledTask -TaskName $DataCollectorName

$Settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Days 1)
$Settings.CimInstanceProperties.Item('MultipleInstances').Value = 3   # 3 corresponds to 'Stop the existing instance'

$NewTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday -At 12:00AM

Set-ScheduledTask -TaskName $Task.TaskName -TaskPath $Task.TaskPath -Trigger $NewTrigger -Settings $Settings





