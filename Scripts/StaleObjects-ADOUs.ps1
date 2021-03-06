<#
Cleanup Stale Objects

Pre-Requisites
a. Ensure AD Recycle Bin is enabled (Requires Forest Functional Level 2k08 or higher)

#>

Import-Module ActiveDirectory


# Get empty AD Organizational Units
$OUs = Get-ADOrganizationalUnit -Filter * | ForEach-Object { If ( !( Get-ADObject -Filter * -SearchBase $_ -SearchScope OneLevel) ) { $_ } } | Select-Object Name, DistinguishedName

# CSV Export for review
$OUs | Export-CSV C:\Temp\StaleObjects.csv -NoTypeInformation

# Read OU DistinguishedName from csv file
$OUs = Import-Csv -Path C:\Imports\StaleObjects-2021.csv
  
# Delete Inactive OUs
ForEach ($OU in $OUs){
  Remove-ADOrganizationalUnit -Identity $OU.DistinguishedName -Confirm:$false
}
