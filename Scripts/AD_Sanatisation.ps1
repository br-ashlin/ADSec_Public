#Ben Ashlin for AD Discovery and Sanatisation


import-module ActiveDirectory

#Variables

$usernames = Get-Content C:\temp\Users.txt                    # Input for Users to query
$date = (Get-Date)
$IncactiveDate = (Get-Date).Adddays(-($DaysInactive))
$DaysInactive = 180                    # Days inactive to identify stale accounts
$logdir = 'D:\Ben\Ps'                    # Directory for Log Files

$sanatisedusers = @()
$failedusers =@()
$disabled =@()
$PassExp =@()
$Stale = @()
$locked = @()
$resource = @()
$mailenabled = @()

#Sanatize List

foreach ($user in $usernames) {

#Query AD for Users in List
Try {
$sanatised = Get-ADuser $user -Properties Enabled, LockedOut, PasswordExpired, LastLogonDate, Mail -ErrorAction SilentlyContinue
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


foreach ($user in $sanatisedusers) {
Write-Host "Checking Active Directory Attributes for $user... " -ForegroundColor Cyan
}

$resource = $sanatisedusers | Where-Object {($_.Enabled -eq $false) -AND ($_.Mail -NE $NULL)}
$disabled = $sanatisedusers | Where-Object {($_.Enabled -eq $false) -AND ($_.Mail -eq $NULL)}
$locked = $sanatisedusers | Where-Object {$_.LockedOut -eq $true} | Select -ExpandProperty sAmAccountName
$passexp = $sanatisedusers | Where-Object {$_.PasswordExpired -eq $true}
$mailenabled = $sanatisedusers |  Where-Object {$_.Mail -ne $NULL}
$stale = $sanatisedusers | Where-Object {($_.LastLogonDate -lt $IncactiveDate) -AND ($_.Enabled -eq $true) -AND ($_.LastLogonDate -ne $NULL)}



#Out to File for Variables

$resource | Select sAmAccountName, Mail | Out-File "$logdir\resource-accounts.txt" -Append 
$disabled | Select sAmAccountName, Enabled | Out-File "$logdir\disabled-accounts.txt" -Append 
$locked | Select sAmAccountName, LockedOut|  Out-File "$logdir\locked-accounts.txt" -Append 
$PassExp | Select sAmAccountName, PasswordExpired |  Out-File "$logdir\Password-Expired-accounts.txt" -Append 
$stale | Select sAmAccountName, LastlogonDate, Enabled |  Out-File "$logdir\stale-accounts.txt" -Append
$failedusers |  Out-File "$logdir\failed-lookup-accounts.txt" -Append 
$mailenabled | Select sAmAccountName, Mail | Out-File "$logdir\mail-enabled-accounts.txt" -Append

#Output Counts for Variables

Write-Host "Resource Accounts in Phase 3:"$resource.Count  -ForegroundColor Yellow
Write-Host "Disabled Accounts in Phase 3:"$disabled.count  -ForegroundColor yellow
Write-Host "Locked Out Accounts in Phase 3:"$Locked.count  -ForegroundColor yellow
Write-Host "Accounts with Expired Passwords in Phase 3:"$PassExp.count  -ForegroundColor yellow
Write-Host "Stale Accounts in Phase 3:"$Stale.count  -ForegroundColor yellow
Write-Host "Users could not be found in Phase 3:"$failedusers.Count  -ForegroundColor Yellow
Write-Host  "Users are mail-enabled in Phase 3:"$mailenabled.Count -ForegroundColor Yellow