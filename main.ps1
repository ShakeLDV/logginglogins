# https://theposhwolf.com/howtos/Get-LoginEvents/
Function Get-LoginEvents {
    Param (
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('Name')]
        [string]$ComputerName = $env:ComputerName
        ,
        [datetime]$StartTime
        ,
        [datetime]$EndTime
    )
    Begin {
        enum LogonTypes {
            Interactive = 2
            Network = 3
            Batch = 4
            Service = 5
            Unlock = 7
            NetworkClearText = 8
            NewCredentials = 9
            RemoteInteractive = 10
            CachedInteractive = 11
        }
        $filterHt = @{
            LogName = 'Security'
            ID = 4624
        }
        if ($PSBoundParameters.ContainsKey('StartTime')){
            $filterHt['StartTime'] = $StartTime
        }
        if ($PSBoundParameters.ContainsKey('EndTime')){
            $filterHt['EndTime'] = $EndTime
        }
    }
    Process {
        Get-WinEvent -ComputerName $ComputerName -FilterHashtable $filterHt | foreach-Object {
            [pscustomobject]@{
                ComputerName = $ComputerName
                UserAccount = $_.Properties.Value[5]
                UserDomain = $_.Properties.Value[6]
                LogonType = [LogonTypes]$_.Properties.Value[8]
                WorkstationName = $_.Properties.Value[11]
                SourceNetworkAddress = $_.Properties.Value[19]
                TimeStamp = $_.TimeCreated
            }
        }
    }
    End{}
}

Function Get-LoginList ($room, $rmnum) {
#     $list_computers = (Get-ADComputer -Filter * -SearchBase $($room)).Name
#     foreach ($computer in $list_computers) {
#     Write-Host("Looking through the audit logs of $($computer)")
#     $computer | 
#     Get-LoginEvents -StartTime (Get-Date).AddDays(-7) | 
#     Where-Object {$_.UserDomain -ilike "CEI"}| Where-Object LogonType -eq 'Interactive' |
#     Select-Object -Property ComputerName, UserAccount, UserDomain, TimeStamp |
#     Export-Csv -Path ".\LoginCount $($rmnum) $((Get-Date).ToString('MM-dd-yyyy')).csv" -NoTypeInformation -Append
# }

}


$RM518 = "OU=RM 518,OU=Lab,OU=Building 5,OU=IF Classroom,OU=CEI Computers,DC=CEI,DC=EDU"
$RM516 = "OU=RM 516,OU=Lab,OU=Building 5,OU=IF Classroom,OU=CEI Computers,DC=CEI,DC=EDU"
$RM508 = "OU=RM 508,OU=Lab,OU=Building 5,OU=IF Classroom,OU=CEI Computers,DC=CEI,DC=EDU"
#Library 
$RM526 = "OU=RM 526,OU=Open Lab,OU=Building 5,OU=IF Classroom,OU=CEI Computers,DC=CEI,DC=EDU"

$list_computers = (Get-ADComputer -Filter * -SearchBase $RM518).Name
    foreach ($computer in $list_computers) {
    Write-Host("Looking through the audit logs of $($computer)")
    $computer | 
    Get-LoginEvents -StartTime (Get-Date).AddDays(-7) | 
    Where-Object {$_.UserDomain -ilike "CEI"}| Where-Object LogonType -eq 'Interactive' |
    Select-Object -Property ComputerName, UserAccount, UserDomain, TimeStamp |
    Export-Csv -Path ".\LoginCount RM518 $((Get-Date).ToString('MM-dd-yyyy')).csv" -NoTypeInformation -Append
}