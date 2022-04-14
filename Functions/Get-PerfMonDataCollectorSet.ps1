Function Get-PerfMonDataCollectorSet {

<#
    .SYNOPSIS
        Retrieves a Perfmon Data Collector Set

    .PARAMETER DataCollectorSetName
        Name of the Data Collector set to retrieve.

    .LINK
        https://www.powershellgallery.com/packages/dbatools/0.9.188/Content/functions%5CGet-DbaPfDataCollectorSet.ps1
#>

    [CmdletBinding()]
    Param (
        [Parameter (Mandatory = $True, ValueFromPipeline = $True)]
        [String[]]$DataCollectorSetName
    )

    Begin {
        $sets = New-Object -ComObject Pla.DataCollectorSet
    }

    Process {
        Foreach ( $D in $DataCollectorSetName ) {
            Write-Verbose "Getting information for data collector set $D"

            # Query changes $sets so work from there
            # ----- redirect error stream to variable so we can see if there was an error
            $E = $($sets.Query($D, $null)) 2>&1

            if ( $E ) {
                write-Warning "Get-PerfmonDataCollectorSet : Error `n`n$E"
                
                # ----- Reset Error var back to null
                $E = $Null
            }
            Else {
                $set = $sets.PSObject.Copy()

                Write-Output $set
            }
        }
    }
}