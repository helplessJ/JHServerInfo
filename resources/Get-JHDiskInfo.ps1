Function Get-JHDiskInfo {
  [cmdletbinding()]
  param(
    [parameter(ValueFromPipeline)]
    [ValidateScript(
      {test-connection -ComputerName $_ -Count 1 -Quiet}
    )]
    [string]$ServerName = $(throw 'Need a server name!'),

    [parameter()]
    [ValidateScript(
      {$_.getType().name -eq 'Int32'}
    )]
    [int32]$PercentFreeRequired = 25
  )

  $disks = @()
  $diskSplat = @{
    Class        = 'Win32_LogicalDisk'
    Filter       = "DriveType = 3"
    ComputerName = $ServerName
  }
  $diskInfo = Get-WmiObject @diskSplat
  foreach ($drive in $diskInfo) {
    $percentFree = $drive.FreeSpace / $drive.Size * 100
    $props = [ordered]@{
      DriveLetter          = $drive.DeviceID
      Label                = $drive.VolumeName
      SizeGB               = [math]::Round(($drive.Size / 1GB), 2)
      FreeGB               = [math]::Round(($drive.FreeSpace / 1GB), 2)
      PercentFree          = [math]::Round($percentFree, 0)
      "IncreaseDiskTo(GB)" = $null
    }
    $disks += New-Object psobject -Property $props
  }

  $diskCount = 0
  foreach ($disk in $disks) {
    IF ($disk.PercentFree -lt $PercentFreeRequired) {
      $x = $PercentFreeRequired - $disk.PercentFree
      $percentOfX = $x * .01
      [decimal]$increaseBy = 1 + $percentOfX
      $disks[$diskCount]."IncreaseDiskTo(GB)" = [Math]::Round($disk.SizeGB * $increaseBy)
    }
    $diskCount++
  }
  $disks
}