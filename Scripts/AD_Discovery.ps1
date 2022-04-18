#Ben Ashlin for AD Discovery - Security Hardening Attributes
#v1.0 - December 2021
#v1.1 - February 2022 - Removed Switches on Group Memberships & SPN Checks
#v1.2 - April 2022 - Cleaned up stale code

Import-Module ActiveDirectory

#Variables
$targetacc = Read-Host ("Enter Service accounts separated by commas") 
$targetacc = $targetacc.split(",")
$inc = Read-Host "Enter Incident number, e.g INC4203141"
$csvloc = Read-Host "Enter location for CSV Export, e.g D:\Temp"


ForEach ($acc in $targetacc) {


#Get AD Properties for Service Accounts

Write-Host "Checking details of $acc from Active Directory" -ForegroundColor Cyan
Write-Host ' '
Get-ADUser -Filter {sAMAccountName -like $acc} -Properties *  | Select-Object DisplayName, sAMAccountName, DistinguishedName, mail, manager,  LastLogonDate, Whencreated, enabled, PasswordLastSet, PasswordNeverExpires, KerberosEncryptionType, TrustedForDelegation, AccountNotDelegated, Description, info 
$groupcount = Get-ADUser -Filter {sAMAccountName -like $acc} -Properties *  | Select-Object -ExpandProperty MemberOf
$logonworkstations = Get-ADUser -Filter {sAMAccountName -like $acc} -Properties *  | Select-Object -ExpandProperty LogonWorkstations
Write-Host "Group Membership Count =" $groupcount.count -ForegroundColor Yellow
Write-Host "Logon Workstations Count =" $logonworkstations.count -ForegroundColor Yellow
Write-Host ' '

Write-Host "$acc is a member of the following Groups" -ForegroundColor Cyan
Write-Host ' '
$groupm = Get-ADUser -Filter {sAMAccountName -like $acc} -Properties memberof  | Select-Object MemberOf

$groupm.memberof

Write-Host ' '
Write-Host "$acc has the following hosts in the 'LogonTo Workstation' list" -ForegroundColor Cyan
Write-Host ' '
Get-ADUser -Filter {sAMAccountName -like $acc} -Properties *  | Select-Object -ExpandProperty LogonWorkstations
Write-Host ' '

}



#Check SPNS associated with Service Accounts
ForEach ($acc in $targetacc) {

Write-Host ''
Write-Host "Checking SPNs associated with $acc" -ForegroundColor Cyan
Write-Host ''
setspn -L $acc
}

#Export to CSV Function
$input = Read-Host "Export to CSV? Press 'Y', 'N' to exit" 

switch ($input) {
'Y'{

ForEach ($acc in $targetacc) {
Get-ADUser -Filter {sAMAccountName -like $acc} -Properties *  | Select-Object DisplayName, sAMAccountName, mail, manager,  LastLogonDate, Whencreated, enabled, PasswordLastSet, PasswordNeverExpires, KerberosEncryptionType, TrustedForDelegation, AccountNotDelegated, Description, info,  LogonWorkstations, MemberOf | Export-Csv $csvloc\$inc.csv -NoClobber -Append -Force

setspn -L $acc | Export-Csv $csvloc\$inc.csv -NoClobber -Append -Force


Write-Host "CSV Exported" $csvloc\$inc.csv
}
}

'N'{
exit
}
'default'
{
exit
}
}
