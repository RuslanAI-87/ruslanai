# setup_flowise.ps1
# Скрипт для автоматической настройки потоков в Flowise

# Настройки
$flowiseUrl = "http://localhost:3000"
$apiUrl = "$flowiseUrl/api/v1"

# Функция для выполнения HTTP-запросов
function Invoke-FlowiseApi {
    param (
        [string]$Endpoint,
        [string]$Method = "GET",
        [object]$Body = $null,
        [string]$ContentType = "application/json"
    )
    
    $fullUrl = "$apiUrl/$Endpoint"
    $params = @{
        Uri = $fullUrl
        Method = $Method
        ContentType = $ContentType
    }
    
    if ($Body -ne $null) {
        if ($Body -is [string]) {
            $params.Body = $Body
        } else {
            $params.Body = $Body | ConvertTo-Json -Depth 10
        }
    }
    
    try {
        $response = Invoke-RestMethod @params
        return $response
    } catch {
        Write-Host "Ошибка при вызове API: $_" -ForegroundColor Red
        Write-Host "URL: $fullUrl" -ForegroundColor Red
        Write-Host "Метод: $Method" -ForegroundColor Red
        if ($Body -ne $null) {
            Write-Host "Тело запроса: $($params.Body)" -ForegroundColor Red
        }
        return $null
    }
}

# Проверяем доступность Flowise
Write-Host "Проверка доступности Flowise API..." -ForegroundColor Cyan
try {
    $healthCheck = Invoke-RestMethod -Uri "$apiUrl/health"
    Write-Host "Flowise доступен и работает." -ForegroundColor Green
} catch {
    Write-Host "Flowise недоступен. Убедитесь, что сервер запущен на $flowiseUrl" -ForegroundColor Red
    Write-Host "Ошибка: $_" -ForegroundColor Red
    exit
}

# Получение списка доступных компонентов
Write-Host "Получение списка компонентов..." -ForegroundColor Cyan
$components = Invoke-FlowiseApi -Endpoint "components"
if ($components -eq $null) {
    Write-Host "Не удалось получить список компонентов. Выход." -ForegroundColor Red
    exit
}
Write-Host "Получено компонентов: $($components.Count)" -ForegroundColor Green

# Создаем credential для OpenAI для начала
Write-Host "Создание учетных данных OpenAI..." -ForegroundColor Cyan
$credentialName = "OpenAI API Key"
$credentials = Invoke-FlowiseApi -Endpoint "credentials"

# Проверяем, существует ли уже такой credential
$openAiCredential = $credentials | Where-Object { $_.name -eq $credentialName }

if ($openAiCredential -eq $null) {
    # Запрос API ключа у пользователя
    $apiKey = Read-Host "Введите ваш OpenAI API ключ"
    
    $credentialData = @{
        name = $credentialName
        credentialType = "openai"
        plainDataObj = @{
            openAIApiKey = $apiKey
        }
    }
    
    $newCredential = Invoke-FlowiseApi -Endpoint "credentials" -Method "POST" -Body $credentialData
    if ($newCredential -eq $null) {
        Write-Host "Не удалось создать учетные данные OpenAI. Выход." -ForegroundColor Red
        exit
    }
    $openAiCredential = $newCredential
    Write-Host "Учетные данные OpenAI созданы успешно. ID: $($openAiCredential.id)" -ForegroundColor Green
} else {
    Write-Host "Учетные данные OpenAI уже существуют. ID: $($openAiCredential.id)" -ForegroundColor Green
}

# Создаем новый chatflow
Write-Host "Создание нового чат-потока..." -ForegroundColor Cyan
$chatflowData = @{
    name = "RuslanAI Orchestrator"
    description = "Основной чат-поток для RuslanAI с поддержкой оркестрации и распознавания речи"
}

$chatflow = Invoke-FlowiseApi -Endpoint "chatflows" -Method "POST" -Body $chatflowData
if ($chatflow -eq $null) {
    Write-Host "Не удалось создать чат-поток. Выход." -ForegroundColor Red
    exit
}
Write-Host "Чат-поток создан успешно. ID: $($chatflow.id)" -ForegroundColor Green

# Финальное сообщение
Write-Host "`n===== Настройка Flowise завершена успешно =====`n" -ForegroundColor Green
Write-Host "Чат-поток 'RuslanAI Orchestrator' создан с ID: $($chatflow.id)" -ForegroundColor Cyan
Write-Host "Теперь вы можете настроить его через интерфейс Flowise: $flowiseUrl/canvas/$($chatflow.id)" -ForegroundColor Cyan
Write-Host "API эндпоинт чат-потока: $flowiseUrl/api/v1/prediction/$($chatflow.id)" -ForegroundColor Cyan
Write-Host "`nВнесите ID чат-потока в код Python-интеграции для работы с оркестратором:" -ForegroundColor Yellow
Write-Host "orchestrator = FlowiseOrchestrator(chatflow_id='$($chatflow.id)')" -ForegroundColor Yellow