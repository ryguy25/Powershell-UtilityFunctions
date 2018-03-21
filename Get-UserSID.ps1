function Get-UserSID {

[CmdletBinding()]

PARAM (

[Parameter()]
[String]$Username = $env:USERNAME,

[Parameter()]
[String]$DomainName = $env:USERDOMAIN

)

$userAccount = New-Object System.Security.Principal.NTAccount($DomainName, $Username)
$userSID = $userAccount.Translate([System.Security.Principal.SecurityIdentifier])

return $userSID.Value

}