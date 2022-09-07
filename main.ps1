# https://theposhwolf.com/howtos/Get-LoginEvents/
Function Get-LoginEvents {
    Param (
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('Name')]
        [string]$ComputerName = $env:ComputerName
        # ,
        # [datetime]$StartTime
        # ,
        # [datetime]$EndTime
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
            StartTime = Get-Date -Date "08/26/2022"
            EndTime = Get-Date -Date "09/02/2022"
        }
        # if ($PSBoundParameters.ContainsKey('StartTime')){
        #     $filterHt['StartTime'] = $StartTime
        # }
        # if ($PSBoundParameters.ContainsKey('EndTime')){
        #     $filterHt['EndTime'] = $EndTime
        # }
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

function Get-Manual {
    $path = (Get-Location).path 
    Get-LoginEvents |
    Where-Object UserDomain -ilike "*CEI*" |
    Where-Object UserAccount -NotLike "ldvadmin01"| 
    Where-Object UserAccount -NotLike "leighiam.virrey"|
    Where-Object LogonType -Like "Interactive" |
    Select-Object -Property ComputerName, UserAccount, UserDomain, LogonType, TimeStamp |
    Export-Csv -Path "$path\LoginCount $((Get-Date).ToString('MM-dd-yyyy')).csv" -NoTypeInformation -Append
}

function Get-Remote {
    Param (
        [string]$RoomOU,
        [string]$RoomNumber
    )
    $list_computers = (Get-ADComputer -Filter * -SearchBase $RoomOU).Name
        foreach ($computer in $list_computers) {
            write-host("The $computer audit log is getting pulled.")
            Invoke-Command -ComputerName $computer -ScriptBlock ${Function:Get-LoginEvents} |
            Where-Object UserDomain -ilike "*CEI*" |
            Where-Object UserAccount -NotLike "ldvadmin01"| 
            Where-Object UserAccount -NotLike "leighiam.virrey"|
            Where-Object LogonType -Like "Interactive" |
            Select-Object -Property ComputerName, UserAccount, UserDomain, LogonType, TimeStamp |
            Export-Csv -Path ".\LoginCount $RoomNumber $((Get-Date).ToString('MM-dd-yyyy')).csv" -NoTypeInformation -Append
        }
}
$RM518 = "OU=RM 518,OU=Lab,OU=Building 5,OU=IF Classroom,OU=CEI Computers,DC=CEI,DC=EDU"
$RM516 = "OU=RM 516,OU=Lab,OU=Building 5,OU=IF Classroom,OU=CEI Computers,DC=CEI,DC=EDU"
$RM508 = "OU=RM 508,OU=Lab,OU=Building 5,OU=IF Classroom,OU=CEI Computers,DC=CEI,DC=EDU"
# Library 
$RM526 = "OU=RM 526,OU=Open Lab,OU=Building 5,OU=IF Classroom,OU=CEI Computers,DC=CEI,DC=EDU"
$RM20 = "OU=RM 25,OU=Lab,OU=Building 1,OU=IF Classroom,OU=CEI Computers,DC=CEI,DC=EDU"
