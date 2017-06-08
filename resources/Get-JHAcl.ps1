Function Get-JHAcl {
    [cmdletbinding()]
  param(
    [parameter(ValueFromPipeline)]
    [ValidateScript(
      {test-connection -Count 1 -Quiet}
    )]
    [string]$ServerName = $(throw 'Need a server name!')
  )
}