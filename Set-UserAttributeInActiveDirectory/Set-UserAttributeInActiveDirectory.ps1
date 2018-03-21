Try {

    ### Import Active Directory Module so we can access the AD: PSDrive and use the Get-ADUser cmdlet
    Import-Module ActiveDirectory -ErrorAction Stop

}

Catch {

    Write-Error $_.Exception.Message

}

Function Set-UserAttributeInActiveDirectory {

[CmdletBinding()]
PARAM(

    [Parameter(Mandatory=$true,Position=0)]
    [ValidateNotNullOrEmpty()]
    [Alias("SamAccountName")]
    [String]$Username,

    [Parameter(Mandatory=$true,Position=1)]
    [ValidateNotNullOrEmpty()]
    [String]$AttributeName,

    [Parameter(Mandatory=$true,Position=2)]
    [ValidateNotNullOrEmpty()]
    [String]$AttributeValue

)

    #region Begin Block
    Begin {

        ### Save location and setup log location
        Try {
            
            $savedLocation = Get-Location
            Set-Location AD:

            $today = Get-Date -Format "yyyy_MMMM_dd"
            $defaultLogLocation = "$env:USERPROFILE\Documents\Set-UserAttritubeInActiveDirectory_$today.log"

        }

        Catch {

            Write-Error $_.Exception.Message

        }

    }
    #endregion Begin Block

    #region Process Block
    Process {

        Try {

            $userADAccount = Get-ADUser $Username
            
            if($userADAccount.DistinguishedName) {

                Set-ItemProperty -Path $userADAccount.DistinguishedName -Name $AttributeName -Value $AttributeValue

            }

            else {

                "The 'DistinguishedName' property did not exist for $Username.  Skipping...." | Out-File -FilePath $defaultLogLocation -Append

            }

        }

        Catch {

             

        }

    }
    #endregion Process Block

    #region End Block
    End {

        Set-Location $savedLocation

    }
    #endregion End Block
    
}

