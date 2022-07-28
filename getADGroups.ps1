Import-Module ActiveDirectory
Get-ADGroup -filter * | Sort-Object name | Select-Object name