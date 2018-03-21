###  Query for the active power plan
$powerPlan = Get-WmiObject -Namespace "root\cimv2\power" -Class Win32_PowerPlan | Where-Object {$_.IsActive}

###  We need to get the data index values for the active power plan
$powerPlanIndex = $powerPlan.GetRelated("Win32_PowerSettingDataIndex")

###  Loop through the index values and look for any USB power setting entries
foreach ($index in $powerPlanIndex) {

    ### Look at the actual power setting that this index value references
    $setting = $index.GetRelated("Win32_PowerSetting")
        
    ### We need to parse the InstanceIDs to find the scheme GUID, subgroup GUID, setting GUID, and power type (AC or DC)
    ### The index Instance ID takes the format of "Microsoft:PowerSettingDataIndex\{PowerPlan GUID}\{AC or DC}\{PowerSetting GUID} 
    ### The subgroup Instance ID takes the format of "Microsoft:PowerSettingSubgroup\{Subgroup GUID}
    $indexInstanceID = $index.InstanceID.Split("\")
    $subgroup = $setting.GetRelated("Win32_PowerSettingSubgroup")
    
    ### Not all settings have a subgroup, so we need to make sure $subgroup isn't a null value
    if ($subgroup -ne $null) {
        $subgroupInstanceID = $subgroup.InstanceID.Split("\")
    }
    
    $ACorDC = $indexInstanceID[2]
    $schemeGUID = $indexInstanceID[1].Trim("{}")
    $subgrouGUID = $subgroupInstanceID[1].Trim("{}")
    $settingGUID = $indexInstanceID[3].Trim("{}")


    ### If the ElementName field contains the string "USB" AND the PowerSetting is for AC (Plugged in)
    if ( ($setting.ElementName -match "USB") -and ($ACorDC -eq "AC") ) {
        $index.SetPropertyValue("SettingIndexValue", 0)
        $index.Put() | Out-Null
        #powercfg /setacvalueindex $schemeGUID $subgrouGUID $settingGUID 0    
        #powercfg /q $schemeGUID $subgrouGUID
    }
}
#$powerPlan.Activate()
### Query the USB settings for the active power plan.
### Kirkland Peak Power Plan:  
### USB Settings GUID:   2a737441-1930-4402-8d77-b2bebba308a3
$powerPlan.Activate()
powercfg /q $schemeGUID 2a737441-1930-4402-8d77-b2bebba308a3