#import modules
Import-Module ActiveDirectory

#Query user for group to be exported to CSV
#saves as variable 'groupName'
$groupName = read-host "Enter the group name to be exported to a CSV: "

#saves filepath as variable 'filePath' - 2 options

#interactive
#$filePath = read-host "Enter the location for CSV to be saved to: "

#no input needed
#filepath = /[path/to/file]

#Calls two previously saved variables to complete an export of the defined AD group
Get-ADGroupMember -identity $groupName | Select-Object name | Export-csv -path $filePath -Notypeinformation