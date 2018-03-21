Function Remove-ExchangePSSession {

    Get-PSSession | Where-Object {$_.ConfigurationName -eq "Microsoft.Exchange"} | Remove-PSSession
    Get-Module | Where-Object {$_.Name -like 'tmp*'} | Remove-Module

}