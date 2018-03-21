Function Create-ExchangePSSession {

[CmdletBinding()]
PARAM(

    [Parameter(Mandatory=$true)]
    [String]$ExchangeServerURI

)

    #Check for existing PSSession
    $existingPSSessions = Get-PSSession | Where-Object -Property ConfigurationName -EQ -Value "Microsoft.Exchange"
    $sessionFound = $false
    
    if ( $existingPSSessions ) {

        foreach ($session in $existingPSSessions ) {

            if ( ($session.State -eq "Opened") -and ($session.Availability -eq "Available") ) {

                $sessionFound = $true
                Write-Output "Found active PSSession with ID $($session.Id) connected to $($session.ComputerName).  Ok to proceed with Exchange Cmdlets."

            }

        }

    }

    if ($sessionFound -eq $false) {

        $adminCredential = Get-Credential
    
         Try {

            $exchSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeServerURI -Authentication Kerberos -Credential $adminCredential -ErrorAction Stop
            Import-PSSession $exchSession -Verbose:$false

        }

        Catch {

            Write-Error $_.Exception

        }
    
    }

}