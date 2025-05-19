# setup_flowise.ps1
# Скрипт для автоматической настройки потоков в Flowise с поддержкой аутентификации

# Настройки
$flowiseUrl = "http://localhost:3000"
$apiUrl = "$flowiseUrl/api/v1"

# Запрос учетных данных для Flowise
$flowiseUsername = Read-Host "Введите имя пользователя Flowise"
$flowisePassword = Read-Host -AsSecureString "Введите пароль Flowise"
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($flowisePassword)
$flowisePasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Аутентификация в Flowise и получение токена
Write-Host "Выполняем вход в Flowise..." -ForegroundColor Cyan
$authBody = @{
    username = $flowiseUsername
    password = $flowisePasswordPlain
} | ConvertTo-Json

try {
    $authResponse = Invoke-RestMethod -Uri "$flowiseUrl/api/v1/login" -Method POST -Body $authBody -ContentType "application/json"
    $authToken = $authResponse.accessToken
    Write-Host "Аутентификация успешна." -ForegroundColor Green
} catch {
    Write-Host "Ошибка при аутентификации в Flowise: $_" -ForegroundColor Red
    exit
}

# Функция для выполнения HTTP-запросов с токеном
function Invoke-FlowiseApi {
    param (
        [string]$Endpoint,
        [string]$Method = "GET",
        [object]$Body = $null,
        [string]$ContentType = "application/json"
    )
    
    $fullUrl = "$apiUrl/$Endpoint"
    $headers = @{
        "Authorization" = "Bearer $authToken"
    }
    
    $params = @{
        Uri = $fullUrl
        Method = $Method
        ContentType = $ContentType
        Headers = $headers
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
    $healthCheck = Invoke-FlowiseApi -Endpoint "health"
    Write-Host "Flowise доступен и работает." -ForegroundColor Green
} catch {
    Write-Host "Flowise недоступен или ошибка аутентификации. Проверьте учетные данные." -ForegroundColor Red
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

# Найдем необходимые компоненты
$llmComponent = $components | Where-Object { $_.name -eq "ChatOpenAI" } | Select-Object -First 1
$bufferMemoryComponent = $components | Where-Object { $_.name -eq "Buffer Memory" -or $_.name -eq "Message History Memory" } | Select-Object -First 1
$conversationalChainComponent = $components | Where-Object { $_.name -eq "Conversational Retrieval QA Chain" } | Select-Object -First 1
$chatComponent = $components | Where-Object { $_.name -eq "Chat" } | Select-Object -First 1

if ($llmComponent -eq $null -or $bufferMemoryComponent -eq $null -or 
    $conversationalChainComponent -eq $null -or $chatComponent -eq $null) {
    Write-Host "Не удалось найти все необходимые компоненты. Выход." -ForegroundColor Red
    Write-Host "Отсутствуют компоненты:" -ForegroundColor Red
    if ($llmComponent -eq $null) { Write-Host "- ChatOpenAI" -ForegroundColor Red }
    if ($bufferMemoryComponent -eq $null) { Write-Host "- Buffer Memory или Message History Memory" -ForegroundColor Red }
    if ($conversationalChainComponent -eq $null) { Write-Host "- Conversational Retrieval QA Chain" -ForegroundColor Red }
    if ($chatComponent -eq $null) { Write-Host "- Chat" -ForegroundColor Red }
    
    # Выведем список доступных компонентов
    Write-Host "`nДоступные компоненты памяти:" -ForegroundColor Yellow
    $components | Where-Object { $_.category -eq "Memory" } | ForEach-Object { Write-Host "- $($_.name)" -ForegroundColor Yellow }
    
    Write-Host "`nДоступные компоненты моделей:" -ForegroundColor Yellow
    $components | Where-Object { $_.category -eq "LLMs" } | ForEach-Object { Write-Host "- $($_.name)" -ForegroundColor Yellow }
    
    Write-Host "`nДоступные компоненты цепочек:" -ForegroundColor Yellow
    $components | Where-Object { $_.category -eq "Chains" } | ForEach-Object { Write-Host "- $($_.name)" -ForegroundColor Yellow }
    
    Write-Host "`nДоступные компоненты конечных точек:" -ForegroundColor Yellow
    $components | Where-Object { $_.category -eq "Endpoints" } | ForEach-Object { Write-Host "- $($_.name)" -ForegroundColor Yellow }
    
    exit
}

# Позиции для компонентов
$llmPosition = @{ top = 100; left = 100 }
$memoryPosition = @{ top = 300; left = 100 }
$chainPosition = @{ top = 200; left = 400 }
$chatPosition = @{ top = 400; left = 400 }

# Создаем узлы
$nodes = @(
    @{
        id = "node_llm"
        data = @{
            id = "node_llm"
            label = "ChatOpenAI"
            name = $llmComponent.name
            type = "ChatOpenAI"
            baseClasses = $llmComponent.baseClasses
            category = "LLMs"
            credential = @{
                credentialId = $openAiCredential.id
                credentialName = $openAiCredential.name
            }
            inputs = @{
                modelName = "gpt-4o"
                temperature = 0.7
                streaming = $true
            }
        }
        position = $llmPosition
        type = "customNode"
        width = 200
        height = 200
    },
    @{
        id = "node_memory"
        data = @{
            id = "node_memory"
            label = $bufferMemoryComponent.name
            name = $bufferMemoryComponent.name
            type = $bufferMemoryComponent.name.Replace(" ", "")
            baseClasses = $bufferMemoryComponent.baseClasses
            category = "Memory"
            inputs = @{
                memoryKey = "chat_history"
                returnMessages = $true
            }
        }
        position = $memoryPosition
        type = "customNode"
        width = 200
        height = 200
    },
    @{
        id = "node_chain"
        data = @{
            id = "node_chain"
            label = "Conversational Retrieval QA Chain"
            name = $conversationalChainComponent.name
            type = "ConversationalRetrievalQAChain"
            baseClasses = $conversationalChainComponent.baseClasses
            category = "Chains"
            inputs = @{
                returnSourceDocuments = $true
            }
        }
        position = $chainPosition
        type = "customNode"
        width = 200
        height = 400
    },
    @{
        id = "node_chat"
        data = @{
            id = "node_chat"
            label = "Chat"
            name = $chatComponent.name
            type = "Chat"
            baseClasses = $chatComponent.baseClasses
            category = "Endpoints"
        }
        position = $chatPosition
        type = "customNode"
        width = 200
        height = 200
    }
)

# Создаем ребра (связи между узлами)
$outputHandle = $bufferMemoryComponent.name.Replace(" ", "")
$edges = @(
    @{
        id = "edge_llm_to_chain"
        source = "node_llm"
        target = "node_chain"
        sourceHandle = "ChatOpenAI"
        targetHandle = "model"
        type = "custom"
        markerEnd = @{
            type = "arrowclosed"
        }
    },
    @{
        id = "edge_memory_to_chain"
        source = "node_memory"
        target = "node_chain"
        sourceHandle = $outputHandle
        targetHandle = "memory"
        type = "custom"
        markerEnd = @{
            type = "arrowclosed"
        }
    },
    @{
        id = "edge_chain_to_chat"
        source = "node_chain"
        target = "node_chat"
        sourceHandle = "ConversationalRetrievalQAChain"
        targetHandle = "chain"
        type = "custom"
        markerEnd = @{
            type = "arrowclosed"
        }
    }
)

# Обновляем чат-поток с созданными узлами и ребрами
$updateData = @{
    id = $chatflow.id
    nodes = $nodes
    edges = $edges
}

$updatedChatflow = Invoke-FlowiseApi -Endpoint "chatflows/$($chatflow.id)" -Method "PUT" -Body $updateData
if ($updatedChatflow -eq $null) {
    Write-Host "Не удалось обновить чат-поток с компонентами. Выход." -ForegroundColor Red
    exit
}
Write-Host "Чат-поток успешно обновлен с компонентами и связями." -ForegroundColor Green

# Настройка распознавания речи
Write-Host "Настройка распознавания речи (Whisper)..." -ForegroundColor Cyan

# Запрос API ключа у пользователя, если еще не задан
if (-not [string]::IsNullOrEmpty($apiKey)) {
    $whisperApiKey = $apiKey
} else {
    $whisperApiKey = Read-Host "Введите ваш OpenAI API ключ для Whisper"
}

$configData = @{
    chatbotConfig = @{
        id = $chatflow.id
        speechToText = @{
            provider = "OPENAI_WHISPER"
            apiKey = $whisperApiKey
            language = "ru"
        }
    }
}

$configResult = Invoke-FlowiseApi -Endpoint "chatflows/$($chatflow.id)/configuration" -Method "POST" -Body $configData
if ($configResult -eq $null) {
    Write-Host "Предупреждение: Не удалось настроить распознавание речи. Проверьте настройки вручную." -ForegroundColor Yellow
} else {
    Write-Host "Распознавание речи Whisper успешно настроено." -ForegroundColor Green
}

# Финальное сообщение
Write-Host "`n===== Настройка Flowise завершена успешно =====`n" -ForegroundColor Green
Write-Host "Чат-поток 'RuslanAI Orchestrator' создан и настроен с ID: $($chatflow.id)" -ForegroundColor Cyan
Write-Host "Вы можете использовать его через интерфейс Flowise: $flowiseUrl/canvas/$($chatflow.id)" -ForegroundColor Cyan
Write-Host "API эндпоинт чат-потока: $flowiseUrl/api/v1/prediction/$($chatflow.id)" -ForegroundColor Cyan
Write-Host "`nВнесите ID чат-потока в код Python-интеграции для работы с оркестратором:" -ForegroundColor Yellow
Write-Host "orchestrator = FlowiseOrchestrator(chatflow_id='$($chatflow.id)')" -ForegroundColor Yellow

# Создаем файл интеграции для Python
$pythonIntegrationCode = @"
# integration_example.py
from flowise_connector import FlowiseConnector

# Инициализация коннектора с ID созданного чат-потока
flowise = FlowiseConnector()
chatflow_id = '$($chatflow.id)'

# Пример использования
def test_connection():
    response = flowise.query_chatflow(
        chatflow_id=chatflow_id,
        question="Привет, это тестовое сообщение от Python-интеграции!"
    )
    print("Ответ от Flowise:", response)

if __name__ == "__main__":
    test_connection()
"@

$pythonIntegrationCode | Out-File -FilePath "C:\RuslanAI\integration_example.py" -Encoding utf8
Write-Host "`nСоздан пример интеграции: C:\RuslanAI\integration_example.py" -ForegroundColor Cyan
