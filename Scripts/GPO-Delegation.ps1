<#
Script will search GPOs in domain and delegate desired permissions to requested Active Directory Group	
#>

$domain = "contoso.domain.com"
$adgroup = "T1_ADSEC_ADS"
$lvl = "GpoEditDeleteModifySecurity"

#Get SID of required AD Group
Get-ADGroup $adgroup | Select SID

#Get GPOs in current domain Not Like "T0"

$gpos = Get-GPO -Domain $domain -All | where {$_.DisplayName -notlike "T0*" } | ForEach-Object {
    # Test if SID of $adgroup have permissions on GPOs
    if ('S-1-5-21-3427012992-3321070574-2069469002-54304' -notin ($_ | Get-GPPermission -Domain $domain -All -ErrorAction SilentlyContinue).Trustee.Sid.Value) {
        $_
    }
} | Select DisplayName, DomainName | Sort-Object DisplayName

#Foreach GPO identified, Set $LVL permissions on those GPOS.
#Remove Comments "<# , #>" to action


foreach ($gpo in $gpos) {
 
Set-GPPermission -Name $gpo.Displayname -DomainName $domain -PermissionLevel $lvl -TargetName $adgroup -TargetType Group -Verbose

}
