# Скрипт для создания чат-потока через API Flowise
$flowiseUrl = "http://localhost:3000"
$openaiApiKey = "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"

# Функция для взаимодействия с API
function Invoke-FlowiseAPI {
    param (
        [string]$Endpoint,
        [string]$Method = "GET",
        [object]$Body = $null
    )
    
    $apiUrl = "$flowiseUrl/api/v1/$Endpoint"
    
    $params = @{
        Uri = $apiUrl
        Method = $Method
        ContentType = "application/json"
    }
    
    if ($Body) {
        $jsonBody = $Body | ConvertTo-Json -Depth 10
        $params.Body = $jsonBody
    }
    
    try {
        $response = Invoke-RestMethod @params
        return $response
    }
    catch {
        Write-Host "Ошибка при обращении к API: $_" -ForegroundColor Red
        Write-Host "URL: $apiUrl" -ForegroundColor Red
        if ($Body) {
            Write-Host "Body: $($jsonBody)" -ForegroundColor Red
        }
        return $null
    }
}

# Создание учетных данных для OpenAI
Write-Host "Создание учетных данных OpenAI..." -ForegroundColor Cyan
$credentialData = @{
    name = "OpenAI API Key"
    credentialType = "openai"
    plainDataObj = @{
        openAIApiKey = $openaiApiKey
    }
}

$credential = Invoke-FlowiseAPI -Endpoint "credentials" -Method "POST" -Body $credentialData

if (-not $credential) {
    Write-Host "Не удалось создать учетные данные. Выход." -ForegroundColor Red
    exit
}

Write-Host "Учетные данные созданы успешно. ID: $($credential.id)" -ForegroundColor Green

# Создание чат-потока
Write-Host "Создание чат-потока..." -ForegroundColor Cyan
$chatflowData = @{
    name = "RuslanAI Orchestrator"
    description = "Основной чат-поток для RuslanAI с поддержкой оркестрации"
}

$chatflow = Invoke-FlowiseAPI -Endpoint "chatflows" -Method "POST" -Body $chatflowData

if (-not $chatflow) {
    Write-Host "Не удалось создать чат-поток. Выход." -ForegroundColor Red
    exit
}

Write-Host "Чат-поток создан успешно. ID: $($chatflow.id)" -ForegroundColor Green
Write-Host "URL для доступа к потоку: $flowiseUrl/canvas/$($chatflow.id)" -ForegroundColor Green

# Сохраним ID чат-потока для использования в Python-оркестраторе
$configData = @"
# Конфигурация Flowise для Python-оркестратора
FLOWISE_CHATFLOW_ID = "$($chatflow.id)"
FLOWISE_URL = "http://localhost:3000"
"@

$configData | Out-File -FilePath "C:\RuslanAI\flowise_config.py" -Encoding utf8
Write-Host "Конфигурация сохранена в flowise_config.py" -ForegroundColor Green
