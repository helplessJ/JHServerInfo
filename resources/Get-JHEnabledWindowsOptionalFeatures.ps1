Function Get-JHEnabledOptionalFeatures {
  [cmdletbinding()]
  param(
    [Parameter(valueFromPipeline)]
    [ValidateScript(
      {test-connection $_ -count 1 -quiet} 
    )]
    [string]$ServerName = $(throw 'Need a server name!')
  )

  <#
  can use wmi here since the target server OS does not have the cmdlet Get-OptionalFeature
  we can use Win32_OptionalFeature to find the installed features like .net3.5 etc...
   installState 1 = installed
   installState 2 = not installed
  #>
  Get-WmiObject -Class Win32_OptionalFeature -ComputerName $ServerName | 
    Select-Object Name, installState | 
    Where-Object InstallState -eq 1
}