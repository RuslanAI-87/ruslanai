# critic_agent.py
import os
import logging
import json
from typing import Dict, Any, List, Optional
from datetime import datetime

# Настройка логирования
os.makedirs("C:/RuslanAI/logs", exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    filename="C:/RuslanAI/logs/critic_agent.log"
)
logger = logging.getLogger(__name__)

# Обновляем импорты в соответствии с предупреждениями
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.messages import HumanMessage, AIMessage

# Конфигурация API
OPENAI_API_KEY = "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"

class CriticAgent:
    def __init__(self, api_key=OPENAI_API_KEY):
        self.api_key = api_key
        self.llm = ChatOpenAI(model="gpt-4o", temperature=0, api_key=api_key)
        
        # Счетчик итераций для каждой задачи
        self.revision_counts = {}
        
        # Максимальное количество итераций
        self.max_revisions = 2
        
    def _get_iteration(self, task_id):
        """Получение номера текущей итерации для задачи"""
        return self.revision_counts.get(task_id, 0) + 1
        
    def evaluate(self, original_task, result, specialist_type, task_id=None):
        """
        Оценка результата работы специалиста
        
        Args:
            original_task: Исходное задание
            result: Результат работы специалиста
            specialist_type: Тип специалиста
            task_id: Идентификатор задачи (для отслеживания итераций)
            
        Returns:
            Оценка и рекомендации
        """
        # Если task_id не указан, генерируем его
        if task_id is None:
            task_id = f"task_{datetime.now().strftime('%Y%m%d%H%M%S')}"
            
        # Получение номера итерации
        iteration = self._get_iteration(task_id)
        
        # Создаем системный промпт здесь, а не в __init__
        system_prompt = f"""
        Ты - агент-критик, твоя задача - оценить работу специалиста и определить, 
        соответствует ли результат требованиям. Будь объективным, но не излишне придирчивым.
        
        Исходное задание: {original_task}
        
        Результат работы специалиста ({specialist_type}): {result}
        
        Оцени результат по следующим критериям:
        1. Соответствие задаче (0-10): насколько результат отвечает исходному запросу
        2. Полнота (0-10): охвачены ли все аспекты запроса
        3. Точность (0-10): насколько фактически верен результат
        4. Качество изложения (0-10): структура, ясность, стиль
        
        Общая оценка: сумма баллов / 4
        
        Итерация: {iteration}/3
        
        Требуется ли доработка? 
        - Для первой итерации: при оценке < 7 - да, иначе - нет
        - Для второй итерации: при оценке < 5 - да, иначе - нет
        - Для третьей итерации: всегда нет (автоматическое одобрение)
        
        Если требуется доработка, укажи конкретные рекомендации:
        - [Рекомендация 1]
        - [Рекомендация 2]
        ...
        
        Твой ответ должен быть структурирован в формате JSON:
        {{
            "критерии": {{
                "соответствие_задаче": X,
                "полнота": X,
                "точность": X,
                "качество_изложения": X
            }},
            "общая_оценка": X.X,
            "needs_revision": true/false,
            "рекомендации": [
                "Рекомендация 1",
                "Рекомендация 2"
            ],
            "вывод": "Твое общее заключение о работе"
        }}
        
        Помни, что ты не должен быть излишне критичным, но и не должен пропускать серьезные недочеты.
        """
        
        # Вызов модели
        logger.info(f"Оценка задачи {task_id}, итерация {iteration}")
        
        messages = [
            {"role": "system", "content": system_prompt}
        ]
        
        response = self.llm.invoke(messages)
        
        # Парсинг результата
        try:
            # Извлечение JSON из ответа
            json_str = response.content
            if "```json" in json_str:
                json_str = json_str.split("```json")[1].split("```")[0].strip()
            elif "```" in json_str:
                json_str = json_str.split("```")[1].split("```")[0].strip()
                
            critique = json.loads(json_str)
            
            # Увеличение счетчика итераций для задачи
            self.revision_counts[task_id] = iteration
            
            # Логирование
            logger.info(f"Результат оценки: {critique}")
            
            # Добавляем метаданные
            critique["task_id"] = task_id
            critique["iteration"] = iteration
            critique["timestamp"] = datetime.now().isoformat()
            
            return critique
        except Exception as e:
            logger.error(f"Ошибка при парсинге результата оценки: {e}")
            logger.error(f"Ответ: {response.content}")
            
            # Формируем результат ошибки
            return {
                "error": f"Ошибка при парсинге результата: {str(e)}",
                "task_id": task_id,
                "iteration": iteration,
                "timestamp": datetime.now().isoformat(),
                "needs_revision": iteration < self.max_revisions  # Если не последняя итерация, требуется доработка
            }
    
    def is_final_iteration(self, task_id):
        """Проверка, является ли итерация последней"""
        current_iteration = self.revision_counts.get(task_id, 0)
        return current_iteration >= self.max_revisions

# Функция для тестирования
def test_critic():
    print("Тестирование агента-критика...")
    
    critic = CriticAgent()
    
    # Тестовое задание
    original_task = "Выполни SEO-аудит сайта example.com и предложи рекомендации по улучшению"
    
    # Тестовый результат (намеренно с недочетами)
    test_result_poor = """
    SEO-аудит сайта example.com
    
    На сайте обнаружены следующие проблемы:
    - Отсутствуют мета-теги
    - Медленная загрузка страниц
    
    Рекомендации:
    1. Добавить мета-теги
    2. Ускорить загрузку страниц
    """
    
    # Тестовый результат (хороший)
    test_result_good = """
    # Полный SEO-аудит сайта example.com
    
    ## Технический анализ
    - Скорость загрузки: 3.5 секунды (требуется оптимизация)
    - Мобильная версия: отсутствует
    - SSL-сертификат: корректный
    - Robots.txt: настроен правильно
    - Sitemap.xml: отсутствует
    
    ## Анализ мета-тегов
    - Title: присутствует, но не оптимизирован (слишком короткий)
    - Description: отсутствует на 60% страниц
    - H1-H6: структура заголовков нарушена
    
    ## Контентный анализ
    - Уникальность контента: 85%
    - Плотность ключевых слов: низкая
    - Структура текста: требует улучшения
    
    ## Анализ обратных ссылок
    - Количество: 156
    - Качество: среднее
    - Разнообразие: низкое
    
    ## Рекомендации
    1. Оптимизировать скорость загрузки путем сжатия изображений и минификации CSS/JS
    2. Разработать мобильную версию сайта
    3. Добавить и оптимизировать мета-теги на всех страницах
    4. Создать и добавить Sitemap.xml
    5. Улучшить структуру заголовков
    6. Увеличить плотность ключевых слов в контенте
    7. Диверсифицировать профиль обратных ссылок
    
    ## Приоритеты внедрения
    1. Высокий: создание мобильной версии, оптимизация мета-тегов
    2. Средний: улучшение скорости загрузки, добавление Sitemap.xml
    3. Низкий: работа над обратными ссылками
    """
    
    # Тест с плохим результатом
    print("\n=== Оценка плохого результата ===")
    result = critic.evaluate(original_task, test_result_poor, "SEO-аналитик", "test_task_1")
    print(json.dumps(result, ensure_ascii=False, indent=2))
    
    # Тест с хорошим результатом
    print("\n=== Оценка хорошего результата ===")
    result = critic.evaluate(original_task, test_result_good, "SEO-аналитик", "test_task_2")
    print(json.dumps(result, ensure_ascii=False, indent=2))
    
    return "Тестирование завершено"

if __name__ == "__main__":
    test_critic()
