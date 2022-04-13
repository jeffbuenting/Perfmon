<#
    .SYSNOPSIS
        Create Perfmon Data Collector Set.

    .LINKS
        Processor Counters - https://bobcares.com/blog/perfmon-counters-for-cpu-usage/
        Memory Counters - https://bobcares.com/blog/perfmon-counters-for-memory-usage/
        IIS Counters - https://techcommunity.microsoft.com/t5/iis-support-blog/performance-counters-for-monitoring-iis/ba-p/683389
#>

[CmdletBinding()]
Param (
    [String]$DataCollectorName = "IIS Server Stats"
)

# ----- . Source needed functions
. /$PSScriptRoot/Functions/Get-PerfMonDataCollectorSet.ps1

# ----- Does the Set already exist?
$DataCollectorSet = Get-PerfMonDataCollectorSet -DataCollectorSetName $DataCollectorName -ErrorAction SilentlyContinue

if ( -Not $DataCollectorSet ) {
    Write-Verbose "Creating $DataCollectorSet"

    # ----- List of counters to include
    $Counters = @(


    )    






}

