Function Get-JHShareInfo {
  # src https://gallery.technet.microsoft.com/scriptcenter/List-Share-Permissions-83f8c419
  [cmdletbinding()] 
 
  param([Parameter(ValueFromPipeline = $True, 
      ValueFromPipelineByPropertyName = $True)]$Computer = '.')  
 
  $shares = Get-WmiObject -Class win32_share -ComputerName $computer | Select-Object -ExpandProperty Name  
  
  foreach ($share in $shares) {    
    $objShareSec = Get-WMIObject -Class Win32_LogicalShareSecuritySetting -Filter "name='$Share'"  -ComputerName $computer 
    try {  
      $SD = $objShareSec.GetSecurityDescriptor().Descriptor 
      $ACL = @()   
      foreach ($ace in $SD.DACL) {   
        $UserName = $ace.Trustee.Name      
        If ($ace.Trustee.Domain -ne $Null) {$UserName = "$($ace.Trustee.Domain)\$UserName"}    
        If ($ace.Trustee.Name -eq $Null) {$UserName = $ace.Trustee.SIDString }      
        $ACL += New-Object Security.AccessControl.FileSystemAccessRule($UserName, $ace.AccessMask, $ace.AceType)  
      } #end foreach ACE  
      $props = @{
        Share = $share
        ACL = $ACL 
      }          
    } # end try  
    catch { 
      $props = @{
        Share = $share
        ACL   = $Null
      } 
    }
    finally {
      New-Object PSObject -Property $props
    }   
  } # end foreach $share
}