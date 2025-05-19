# RuslanAI Cognitive Memory System - Windows Installation

В этой инструкции описано, как запустить когнитивную систему памяти в Windows.

## Требования

1. **Python 3.8+** - https://www.python.org/downloads/
   * При установке обязательно поставьте галочку "Add Python to PATH"
   
2. **Docker Desktop** - https://www.docker.com/products/docker-desktop/
   * Требуется для запуска Milvus (векторной БД)

## Быстрый запуск

1. **Запустите файл `run_windows.bat`**, который автоматически:
   * Проверит наличие Python и Docker
   * Запустит Milvus в Docker
   * Установит необходимые Python-пакеты
   * Запустит тесты производительности
   * Запустит тесты системы памяти

```
C:\RuslanAI\run_windows.bat
```

## Ручная настройка

Если вы предпочитаете ручную настройку, выполните следующие шаги:

1. **Запустите Docker Desktop**

2. **Откройте PowerShell и перейдите в директорию RuslanAI**:
   ```powershell
   cd C:\RuslanAI
   ```

3. **Запустите Milvus**:
   ```powershell
   docker-compose up -d
   ```

4. **Установите необходимые Python-пакеты**:
   ```powershell
   pip install pymilvus sentence-transformers numpy
   ```

5. **Запустите тест производительности Milvus**:
   ```powershell
   python C:\RuslanAI\test_milvus.py
   ```

6. **Запустите тест системы памяти**:
   ```powershell
   python C:\RuslanAI\test_cognitive_memory.py
   ```

## Остановка Milvus

Когда система больше не нужна, остановите Milvus, чтобы освободить ресурсы:

```powershell
cd C:\RuslanAI
docker-compose down
```

## Структура директорий

```
C:\RuslanAI\
├── central_agent\           # Основные компоненты системы
│   └── modules\
│       └── memory\          # Модули памяти
├── milvus-data\             # Данные Milvus
├── docker-compose.yml       # Конфигурация Docker для Milvus
├── milvus_vector_store.py   # Адаптер для Milvus
├── test_milvus.py           # Тест производительности Milvus
├── test_cognitive_memory.py # Тест системы памяти
└── run_windows.bat          # Скрипт для автозапуска
```

## Решение проблем

### Docker не запускается
Убедитесь, что Docker Desktop запущен и WSL 2 правильно настроен.

### Python не найден
Убедитесь, что Python добавлен в PATH. Проверьте командой `python --version`.

### Ошибки импорта модулей
Установите недостающие пакеты:
```powershell
pip install sentence-transformers torch numpy pymilvus
```

### Milvus не запускается
Проверьте логи Docker:
```powershell
docker logs milvus-standalone
```