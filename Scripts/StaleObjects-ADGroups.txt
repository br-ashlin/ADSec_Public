<#
Cleanup Stale Objects

Pre-Requisites
a. Ensure AD Recycle Bin is enabled (Requires Forest Functional Level 2k08 or higher)

1. Groups within array to be migrated to $TargetOU either via array or CSV, specified by technician
2. Groups within $Target OU will be disabled and or Deleted

#>

Import-Module ActiveDirectory


# Specify target OU.
$TargetOU = "OU=EmptyGroups2021,OU=EmptyGroups,DC=contoso,DC=com"

# Get AD Groups without memberships
$Groups = Get-ADGroup -Filter { Members -notlike "*" } -SearchBase "DC=contoso,DC=com" | Select-Object Name, GroupCategory, DistinguishedName


# CSV Export for review
$Groups | Export-CSV C:\Temp\StaleObjects.csv -NoTypeInformation

# Read user DistinguishedName from csv file and move to Target OU.
$Groups = Import-Csv -Path C:\Imports\StaleObjects-2021.csv
  
foreach ($Group in $Groups) {
Get-ADGroup $Group.DistinguishedName | Move-ADObject -TargetPath $TargetOU }
}

# Delete Inactive Users
ForEach ($Group in $Groups){
Remove-ADGroup -Identity $Group.DistinguishedName -Confirm:$false
}
