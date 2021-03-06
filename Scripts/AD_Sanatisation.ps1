#Ben Ashlin for AD Discovery and Sanatisation

import-module ActiveDirectory

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

$usernames = Get-Content 'C:\Temp\Ben\Scripts\Users.txt'                   # Input for Users to query
$date = (Get-Date)
$IncactiveDate = (Get-Date).Adddays(-($DaysInactive))
$DaysInactive = 180                    # Days inactive to identify stale accounts
$logdir = 'C:\Temp\Ben\Scripts\Results'                    # Directory for Log Files

$sanatisedusers = @()
$failedusers =@()
$disabled =@()
$PassExp =@()
$Stale = @()
$locked = @()
$resource = @()
$mailenabled = @()
$manager = @()
$info = @()

#-----------------------------------------------------------[Functions]------------------------------------------------------------


foreach ($user in $usernames) {

#Query AD for Users in List
Try {
$sanatised = Get-ADuser $user -Properties Enabled, LockedOut, PasswordExpired, LastLogonDate, Mail, Manager, Info -erroraction SilentlyContinue
Write-Host "Found User: $user" -ForegroundColor Green
$sanatisedusers += $sanatised
}

#Users that could not be located.
Catch 
{
$failedusers += $user 
Write-Warning "Could not find User: $user..."
}

}

#Query Sanatised List for:
# 1. Resource Accounts
# 2. Disabled
# 3. Locked Accounts
# 4. Expired Accounts
# 5. Stale Accounts
# 6. Mail-Enabled Accounts
# 7. Manager
# 8. Information


foreach ($user in $sanatisedusers) {
Write-Host "Checking Active Directory Attributes for $user... " -ForegroundColor Cyan
}

$resource = $sanatisedusers | Where-Object {($_.Enabled -eq $false) -AND ($_.Mail -NE $NULL)}
$disabled = $sanatisedusers | Where-Object {($_.Enabled -eq $false) -AND ($_.Mail -eq $NULL)}
$locked = $sanatisedusers | Where-Object {$_.LockedOut -eq $true} | Select -ExpandProperty sAmAccountName
$passexp = $sanatisedusers | Where-Object {$_.PasswordExpired -eq $true  -AND ($_.Enabled -eq $true)}
$mailenabled = $sanatisedusers |  Where-Object {$_.Mail -ne $NULL  -AND ($_.Enabled -eq $true)}
$stale = $sanatisedusers | Where-Object {($_.LastLogonDate -lt $IncactiveDate) -AND ($_.Enabled -eq $true) -AND ($_.LastLogonDate -ne $NULL)}
$manager = $sanatisedusers | Where-Object {$_.Manager -ne $NULL -AND ($_.Enabled -eq $true)}
$info = $sanatisedusers | Where-Object {($_.Info -ne $NULL) -AND ($_.Enabled -eq $true)}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Out to File for Variables

$resource | Select sAmAccountName, Enabled, Mail | Export-CSV "$logdir\resource-accounts.csv" -Append 
$disabled | Select sAmAccountName, Enabled | Export-CSV "$logdir\disabled-accounts.csv" -Append 
$locked | Select sAmAccountName, LockedOut|  Export-CSV "$logdir\locked-accounts.csv" -Append 
$PassExp | Select sAmAccountName, PasswordExpired |  Export-CSV "$logdir\Password-Expired-accounts.csv" -Append 
$stale | Select sAmAccountName, LastlogonDate, Enabled |  Export-CSV "$logdir\stale-accounts.csv" -Append
$failedusers |  Export-CSV "$logdir\failed-lookup-accounts.csv" -Append 
$mailenabled | Select sAmAccountName, Mail | Export-CSV "$logdir\mail-enabled-accounts.csv" -Append
$manager | Select sAmAccountName, Manager | Export-CSV "$logdir\manager-accounts.csv" -Append
$info | Select sAmAccountName, Info | Export-CSV "$logdir\info-accounts.csv" -Append


#Out Counts for Variables
Write-Host "Total Accounts:" $usernames.count  -ForegroundColor Yellow
Write-Host "Total Accounts less Disabled & Cannot be Found:" $totalsanatised.count  -ForegroundColor Yellow
Write-Host "Users could not be Found:"$failedusers.Count  -ForegroundColor Yellow
Write-Host "Disabled Accounts:"$disabled.count  -ForegroundColor yellow
Write-Host "Locked Out Accounts:"$Locked.count  -ForegroundColor yellow
Write-Host "Resource Accounts:"$resource.Count  -ForegroundColor Yellow
Write-Host "Accounts with Expired Passwords:"$PassExp.count  -ForegroundColor yellow
Write-Host "Stale Accounts:"$Stale.count  -ForegroundColor yellow
Write-Host "Resource Accounts:"$resource.Count  -ForegroundColor Yellow
Write-Host "Users are mail-enabled:"$mailenabled.Count -ForegroundColor Yellow
Write-Host "Users with Managers / Owners:"$manager.count -ForegroundColor Yellow
Write-Host "Users with info:"$info.count -ForegroundColor Yellow