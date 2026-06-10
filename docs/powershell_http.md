# power shell http ELK 對街版本

```shell
# 1. 填入您的正確帳密
$User = "elastic"
$Pass = "您的實際密碼"

# 2. 強制讓這一次的視窗允許 HTTPS 自簽憑證，並啟用 TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# 3. 抓取最新一筆 4624 日誌
$Event = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624} -MaxEvents 1

# 4. 轉成標準 UTC 時間與 JSON 物件
$LogBody = [PSCustomObject]@{
    "@timestamp"    = $Event.TimeCreated.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    "computer_name" = $Event.MachineName
    "event_id"      = $Event.Id
    "log_name"      = $Event.LogName
    "level"         = $Event.LevelDisplayName
    "message"       = $Event.Message
} | ConvertTo-Json -Compress

# 5. 製作加密密碼標頭 (Basic Auth)
$Pair = "$($User):$($Pass)"
$Encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($Pair))
$Headers = @{ 
    "Content-Type"  = "application/json"
    "Authorization" = "Basic $Encoded"
}

# 6. 正式發射！
Invoke-RestMethod -Uri 'https://172.16.1.4:9200/win11-logs/_doc' -Method Post -Headers $Headers -Body ([System.Text.Encoding]::UTF8.GetBytes($LogBody))
```


```bash
# 1. 填入您的正確帳密
$User = "elastic"
$Pass = "您的實際密碼"

# 2. 強制讓這一次的視窗允許 HTTPS 自簽憑證，並啟用 TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# 3. 抓取最新一筆 4624 日誌
$Event = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624} -MaxEvents 1

# 4. 轉成標準 UTC 時間與 JSON 物件
$LogBody = [PSCustomObject]@{
    "@timestamp"    = $Event.TimeCreated.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
    "computer_name" = $Event.MachineName
    "event_id"      = $Event.Id
    "log_name"      = $Event.LogName
    "level"         = $Event.LevelDisplayName
    "message"       = $Event.Message
} | ConvertTo-Json -Compress

# 5. 製作加密密碼標頭 (Basic Auth)
$Pair = "$($User):$($Pass)"
$Encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($Pair))
$Headers = @{ 
    "Content-Type"  = "application/json"
    "Authorization" = "Basic $Encoded"
}

# 6. 正式發射！
Invoke-RestMethod -Uri 'https://172.16.1.4:9200/win11-logs/_doc' -Method Post -Headers $Headers -Body ([System.Text.Encoding]::UTF8.GetBytes($LogBody))
```