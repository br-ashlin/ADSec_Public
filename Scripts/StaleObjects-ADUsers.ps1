<#
Cleanup Stale Objects

Pre-Requisites
a. Ensure AD Recycle Bin is enabled (Requires Forest Functional Level 2k08 or higher)
b. Review the options for Disable, Delete and Disable 'Protect from Accidental Deletion'.
c. Set the target Inactive Days at $DaysInactive

1. Users within array to be migrated to $TargetOU either via array or CSV, specified by technician
2. After users have been migrated, script will Disable 'Protect from Accidental Deletion' at OU level
3. Users within $Target OU will be disabled and or Deleted

#>

Import-Module ActiveDirectory

# Set the number of days since last logon
$DaysInactive = 90
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))

# Specify target OU.
$TargetOU = "OU=Disabled2021,OU=DisabledUsers,DC=contoso,DC=com"

# Get AD Users that haven't logged on in xx days
$Users = Get-ADUser -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object sAMAccountName, LastLogonDate, DistinguishedName

# CSV Export for review
$Users | Export-CSV C:\Temp\StaleObjects.csv

# Read user sAMAccountNames from csv file and move to Target OU.
$Users = Import-Csv -Path C:\Imports\StaleObjects-2021.csv
  
foreach ($User in $Users) {
Get-ADUser $User.sAMAccountName | Move-ADObject -TargetPath $TargetOU }

# Read user sAMAccountNames from array and move to Target OU. 
foreach ($User in $Users) {
Get-ADUser $User.sAmAccountName | Move-ADObject -TargetPath $TargetOU }

# Disable Protect From Accidental Deletion by OU
$Users = Get-ADUser -ldapfilter “(objectclass=user)” -searchbase "$TargetOU"
ForEach($User in $Users) {
Set-ADObject -Identity $User -ProtectedFromAccidentalDeletion:$false
}

# Delete Inactive Users
ForEach ($User in $Users){
Remove-ADUser -Identity $User.sAmAccountName -Confirm:$false
}
