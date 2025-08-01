# Check-Services.ps1

$services = Get-Content ".\services.txt"
$logFile = ".\service_check_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"

foreach ($service in $services) {
    $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if ($null -eq $svc) {
        "$time - ❌ Service not found: $service" | Tee-Object -FilePath $logFile -Append
        continue
    }

    if ($svc.Status -eq 'Running') {
        "$time - ✅ $service is running" | Tee-Object -FilePath $logFile -Append
    } else {
        "$time - ⚠️ $service is $($svc.Status)" | Tee-Object -FilePath $logFile -Append
        try {
            Start-Service -Name $service -ErrorAction Stop
            "$time - 🔄 Attempted restart: $service" | Tee-Object -FilePath $logFile -Append
        } catch {
            "$time - ❌ Failed to restart: $service" | Tee-Object -FilePath $logFile -Append
        }
    }
}

Write-Host "🩺 Service check completed. Log saved to $logFile"
