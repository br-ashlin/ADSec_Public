<#
Cleanup Stale Objects

Pre-Requisites
a. Ensure AD Recycle Bin is enabled (Requires Forest Functional Level 2k08 or higher)
b. Review the options for Disable, Delete and Disable 'Protect from Accidental Deletion'.
c. Set the target Inactive Days at $DaysInactive

1. Computers within array to be migrated to $TargetOU either via array or CSV, specified by technician
2. After Computers have been migrated, script will Disable 'Protect from Accidental Deletion' at OU level
3. Computers within $Target OU will be disabled and or Deleted

#>

Import-Module ActiveDirectory

# Set the number of days since last logon
$DaysInactive = 90
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))

# Specify target OU.
$TargetOU = "OU=Disabled2021,OU=DisabledComputers,DC=contoso,DC=com"

# Get AD Computers that haven't logged on in xx days
$Computers = Get-ADComputer -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object sAMAccountName, LastLogonDate, DistinguishedName

#CSV Export for review
$Computers | Export-CSV C:\Temp\StaleObjects.csv

# Read Computer sAMAccountNames from csv file and move to Target OU.
$Computers = Import-Csv -Path C:\Imports\StaleObjects-2021.csv
  
foreach ($Computer in $Computers) {
Get-ADComputer $Computer.sAMAccountName | Move-ADObject -TargetPath $TargetOU }

# Read Computer sAMAccountNames from array and move to Target OU. 
foreach ($Computer in $Computers) {
Get-ADComputer $Computer.sAmAccountName | Move-ADObject -TargetPath $TargetOU }


# isable Protect From Accidental Deletion by OU
$Computers = Get-ADComputer -ldapfilter “(objectclass=Computer)” -searchbase "$TargetOU"
ForEach($Computer in $Computers) {
Set-ADObject -Identity $Computer -ProtectedFromAccidentalDeletion:$false
}


# Delete Inactive Computers
ForEach ($Computer in $Computers){
Remove-ADComputer -Identity $Computer.sAmAccountName -Confirm:$false
}
