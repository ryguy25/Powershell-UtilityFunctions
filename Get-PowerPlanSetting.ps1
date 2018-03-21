<#
.Synopsis
   Queries the specified system for Windows Power Plans
.DESCRIPTION
   Queries for either a list of all defined power plans on the system and returns an array of strings that represent the names of the 
   power plans or returns a System.Management.ManagementObject referencing a specified power plan
.EXAMPLE
   Get-PowerPlan

   Returns a list of all available power plans for the specified system
.EXAMPLE
   Get-PowerPlan -Name "Balanced"

   Returns the WMI object (Win32_PowerPlan) definition for the "Balanced" power plan
.EXAMPLE
   Get-PowerPlan -Active

   Returns the WMI object (Win32_PowerPlan) definition for the currently active power plan
#>
function Get-PowerPlanSetting
{
    [CmdletBinding()]
    Param
    (
        [Parameter()]
        [string]$ElementName = "*",

        [Parameter()]
        [ValidateSet("AC","DC")]
        [string]$PowerSetting 
    )

    Begin {
    
        ###  Query for the active power plan
        $wmiPowerPlan = Get-WmiObject -Namespace "root\cimv2\power" -Class Win32_PowerPlan | Where-Object {$_.IsActive}

        ###  We need to get the data index values for the active power plan
        $wmiPowerSettingDataIndex = $wmiPowerPlan.GetRelated("Win32_PowerSettingDataIndex")
            
    }
    
    Process {

        ###  Loop through the index values and look for any USB power setting entries
        foreach ($index in $wmiPowerSettingDataIndex) {

            ### Look at the actual power setting that this index value references
            $wmiPowerSetting = $index.GetRelated("Win32_PowerSetting")
        
            ### We need to parse the InstanceIDs to find the scheme GUID, subgroup GUID, setting GUID, and power type (AC or DC)
    
            ### The index Instance ID takes the format of "Microsoft:PowerSettingDataIndex\{PowerPlan GUID}\{AC or DC}\{PowerSetting GUID} 
            $indexInstanceID = $index.InstanceID.Split("\")
            $ACorDC = $indexInstanceID[2]    
    
            ### If the ElementName field contains the string "USB" AND the PowerSetting is for AC (Plugged in)
            if ( ($wmiPowerSetting.ElementName -match $ElementName) -and ($ACorDC -eq $PowerSetting) ) {
        
                $wmiPowerSettingDefinition = $wmiPowerSetting.GetRelated("Win32_PowerSettingDefinition")
                $wmiPowerSettingDefinitionPossibleValue = $wmiPowerSettingDefinition.GetRelated("Win32_PowerSettingDefinitionPossibleValue")
                $wmiPowerSettingDefinitionRangeData = $wmiPowerSettingDefinition.GetRelated("Win32_PowerSettingDefinitionRangeData")
                        
                "Setting Name               " + $wmiPowerSetting.ElementName
                "Current Setting Value:     " + $index.GetPropertyValue("SettingIndexValue")
                "Possible Values:           "
                if ($wmiPowerSettingDefinitionPossibleValue.Count -gt 0) {
                    foreach ($value in $wmiPowerSettingDefinitionPossibleValue) {
                        "                           " + $value.SettingIndex + " = " + $value.ElementName
                    }
                }
                else {
                    foreach ($range in $wmiPowerSettingDefinitionRangeData) {
                        "                           " + $range.ElementName + " = " + $range.SettingValue
                    }
                }
        
                "--------------------------------------------------------------------------------------"
            }
        }
    
    
    }
    
    End {
    
    
    }
}



