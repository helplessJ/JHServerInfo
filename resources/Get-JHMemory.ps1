Function Get-JHMemory {
    [cmdletbinding()]
  param(
    [parameter(ValueFromPipeline)]
    [ValidateScript(
      {test-connection $_ -Count 1 -Quiet}
    )]
    [string]$ServerName = $(throw 'Need a server name!')
  )

  $wmiMemory = Get-WmiObject -Class win32_memory
}