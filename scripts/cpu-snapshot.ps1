for ($i=0; $i -lt 6; $i++) {
  Get-CimInstance Win32_PerfFormattedData_PerfProc_Process |
    Where-Object { $_.Name -match 'yim|mysqld|java|wsl|redis|etcd|vmmem' } |
    ForEach-Object { "$($_.Name) $($_.PercentProcessorTime)" }
  Start-Sleep -Seconds 2
}
