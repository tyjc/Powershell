#import modules
Import-Module ActiveDirectory

#Query user for group to be exported to CSV
#saves as variable 'groupName'
$groupName = read-host "Enter the group for names to be displayed: "

#uses saved variable to list on screen members of the group
Get-ADGroupMember -identity "$groupName" | Select-Object name -Notypeinformation