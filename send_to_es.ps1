param(
    [int]$EventId = 4624
)

# ===== 這裡填寫您的 ES 伺服器資訊 =====
$ES_URL = "http://172.16.1.4:9200/win11-logs/_doc"

# 如果您的 ES 沒有設定密碼，請讓這兩個變頭保持為空 ""
# 如果有密碼，請填入正確的預設帳號 "elastic" 與密碼
$User = "elastic"
$Pass = "umLZVJfaRhhSqASe"
# ======================================

try {
    # 1. 取得最新一筆指定 Event ID
    if ($EventId -gt 0) {
        $latestEvent = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=$EventId} -MaxEvents 1 -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    else {
        $latestEvent = Get-WinEvent -LogName 'Security' -MaxEvents 1 -ErrorAction SilentlyContinue | Select-Object -First 1
    }

    if (-not $latestEvent) {
        return
    }

    # 2. 建立要送到 ES 的 JSON
    $LogBody = [PSCustomObject]@{
        "@timestamp"    = $latestEvent.TimeCreated.ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        "computer_name" = $latestEvent.MachineName
        "event_id"      = $latestEvent.Id
        "log_name"      = $latestEvent.LogName
        "level"         = $latestEvent.LevelDisplayName
        "message"       = $latestEvent.Message
    } | ConvertTo-Json -Compress -EncounteredControls Skip

    # 3. 準備 HTTP 標頭
    $Headers = @{ "Content-Type" = "application/json" }
    
    # 只有當帳號跟密碼「都有填寫」時，才啟動 Basic Auth 認證
    if ($User -and $Pass) {
        $Pair = "$($User):$($Pass)"
        $Encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($Pair))
        $Headers.Add("Authorization", "Basic $Encoded")
    }

    # 4. 發送到 Elasticsearch
    Invoke-RestMethod -Uri $ES_URL -Method Post -Headers $Headers -Body ([System.Text.Encoding]::UTF8.GetBytes($LogBody)) | Out-Null
}
catch {
    # 記錄錯誤以便除錯
    (Get-Date).ToString("s") + " - " + $_.ToString() | Out-File "C:\Scripts\es_error.txt" -Append
}
