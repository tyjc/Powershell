Function New-RIBUser {
    <#
.SYNOPSIS
  Script to be run after AD User is created.
.DESCRIPTION
  - Adds user to default teams and region based private channel.
.NOTES
  Version:        1.0
  Author:         Ty Collins
  Creation Date:  09/2021
#>


    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String] $TargetUser,
        [Parameter(Mandatory)]
        [String] $Branch
    )

    Write-Warning "

  |+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+DISCLAIMER|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|+|
  ##############################################################################################################
  ##############################################################################################################
  ||||||||||||||||||||||||||||||||||||   I wrote it, and it works for me.   ||||||||||||||||||||||||||||||||||||
  ||||||||||||||  If you run it, and don't understand it, don't blame me when you break something  |||||||||||||
  ##############################################################################################################
  ##############################################################################################################
" -WarningAction Inquire

    Write-Host "Loading needed modules"
    Import-Module MicrosoftTeams
    Write-Host "Loaded MS Teams PS Module"
    Write-Host "All Modules Loaded"

    #Connects to the MSTeams online admin
    #Running it this way allows you to authenticate with MFA if required
    Write-Host "Sign in to O365 admin account in pop-up"
    Connect-MicrosoftTeams

    #Imports CSV list of 'default' teams.
    #Update this with actual file location
    Write-Host "loading CSV..."
    $teams = Import-Csv /path/to/csv.csv
    Write-Host "CSV loaded"

    #Iterates through each column and performs add user
    #Uses the email defined in the beginning to add to teams defined by groupID
    foreach ($team in $teams) {
        Add-TeamUser -GroupId $team.groupID -User $targetUser
        Write-Host "Adding $($team.teamName)..."
        Write-Host "Added to $($team.teamName)"
    }

    #Begin sleep as private channel membership can't be added immediately.
    #Needs time for the permission to the parent team to be recognsied.
    Start-Sleep -Seconds 2

    #Check branch variable
    #Depending on branch variable adds to relevant region based private channel
    switch ($Branch) {
        'Region1' {
            Write-Host "Adding to Region1 General Comms"
            Add-TeamChannelUser -GroupId 'groupID' -DisplayName "General Comms - Region1" -User $targetUser
        }
        'Region2' {
            Write-Host "Adding to Region2 General Comms"
            Add-TeamChannelUser -GroupId 'groupID' -DisplayName "General Comms - Region2" -User $targetUser
        }
        'Region3' {
            Write-Host "Adding to Region3 General Comms"
            Add-TeamChannelUser -GroupId 'groupID' -DisplayName "General Comms - Region3" -User $targetUser
        }
        'Region4' {
            Write-Host "Adding to Region4 General Comms"
            Add-TeamChannelUser -GroupId 'groupID' -DisplayName "General Comms - Region4" -User $targetUser
        }
        'Region5' {
            Write-Host "Adding to Region5 General Comms"
            Add-TeamChannelUser -GroupId 'groupID' -DisplayName "General Comms - Region5" -User $targetUser
        }

    }
    Write-Host "All teams added"

    #Disconnect sessions of powershell for teams
    Write-Host "Disconnecting from teams"
    Disconnect-MicrosoftTeams
    Write-Host "Disconnected from teams"
}