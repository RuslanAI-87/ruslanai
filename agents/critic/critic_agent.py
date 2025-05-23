# critic_agent.py
import os
import logging
import json
from typing import Dict, Any, List, Optional
from datetime import datetime

# ????????? ???????????
os.makedirs("C:/RuslanAI/logs", exist_ok=True)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    filename="C:/RuslanAI/logs/critic_agent.log"
)
logger = logging.getLogger(__name__)

# ????????? ??????? ? ???????????? ? ????????????????
from langchain_openai import ChatOpenAI
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.messages import HumanMessage, AIMessage

# ???????????? API
OPENAI_API_KEY = "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"

class CriticAgent:
    def __init__(self, api_key=OPENAI_API_KEY):
        self.api_key = api_key
        self.llm = ChatOpenAI(model="gpt-4o", temperature=0, api_key=api_key)
        
        # ??????? ???????? ??? ?????? ??????
        self.revision_counts = {}
        
        # ???????????? ?????????? ????????
        self.max_revisions = 2
        
    def _get_iteration(self, task_id):
        """????????? ?????? ??????? ???????? ??? ??????"""
        return self.revision_counts.get(task_id, 0) + 1
        
    def evaluate(self, original_task, result, specialist_type, task_id=None):
        """
        ?????? ?????????? ?????? ???????????
        
        Args:
            original_task: ???????? ???????
            result: ????????? ?????? ???????????
            specialist_type: ??? ???????????
            task_id: ????????????? ?????? (??? ???????????? ????????)
            
        Returns:
            ?????? ? ????????????
        """
        # ???? task_id ?? ??????, ?????????? ???
        if task_id is None:
            task_id = f"task_{datetime.now().strftime('%Y%m%d%H%M%S')}"
            
        # ????????? ?????? ????????
        iteration = self._get_iteration(task_id)
        
        # ??????? ????????? ?????? ?????, ? ?? ? __init__
        system_prompt = f"""
        ?? - ?????-??????, ???? ?????? - ??????? ?????? ??????????? ? ??????????, 
        ????????????? ?? ????????? ???????????. ???? ???????????, ?? ?? ??????? ???????????.
        
        ???????? ???????: {original_task}
        
        ????????? ?????? ??????????? ({specialist_type}): {result}
        
        ????? ????????? ?? ????????? ?????????:
        1. ???????????? ?????? (0-10): ????????? ????????? ???????? ????????? ???????
        2. ??????? (0-10): ???????? ?? ??? ??????? ???????
        3. ???????? (0-10): ????????? ?????????? ????? ?????????
        4. ???????? ????????? (0-10): ?????????, ???????, ?????
        
        ????? ??????: ????? ?????? / 4
        
        ????????: {iteration}/3
        
        ????????? ?? ?????????? 
        - ??? ?????? ????????: ??? ?????? < 7 - ??, ????? - ???
        - ??? ?????? ????????: ??? ?????? < 5 - ??, ????? - ???
        - ??? ??????? ????????: ?????? ??? (?????????????? ?????????)
        
        ???? ????????? ?????????, ????? ?????????? ????????????:
        - [???????????? 1]
        - [???????????? 2]
        ...
        
        ???? ????? ?????? ???? ?????????????? ? ??????? JSON:
        {{
            "????????": {{
                "????????????_??????": X,
                "???????": X,
                "????????": X,
                "????????_?????????": X
            }},
            "?????_??????": X.X,
            "needs_revision": true/false,
            "????????????": [
                "???????????? 1",
                "???????????? 2"
            ],
            "?????": "???? ????? ?????????? ? ??????"
        }}
        
        ?????, ??? ?? ?? ?????? ???? ??????? ?????????, ?? ? ?? ?????? ?????????? ????????? ????????.
        """
        
        # ????? ??????
        logger.info(f"?????? ?????? {task_id}, ???????? {iteration}")
        
        messages = [
            {"role": "system", "content": system_prompt}
        ]
        
        response = self.llm.invoke(messages)
        
        # ??????? ??????????
        try:
            # ?????????? JSON ?? ??????
            json_str = response.content
            if "```json" in json_str:
                json_str = json_str.split("```json")[1].split("```")[0].strip()
            elif "```" in json_str:
                json_str = json_str.split("```")[1].split("```")[0].strip()
                
            critique = json.loads(json_str)
            
            # ?????????? ???????? ???????? ??? ??????
            self.revision_counts[task_id] = iteration
            
            # ???????????
            logger.info(f"????????? ??????: {critique}")
            
            # ????????? ??????????
            critique["task_id"] = task_id
            critique["iteration"] = iteration
            critique["timestamp"] = datetime.now().isoformat()
            
            return critique
        except Exception as e:
            logger.error(f"?????? ??? ???????? ?????????? ??????: {e}")
            logger.error(f"?????: {response.content}")
            
            # ????????? ????????? ??????
            return {
                "error": f"?????? ??? ???????? ??????????: {str(e)}",
                "task_id": task_id,
                "iteration": iteration,
                "timestamp": datetime.now().isoformat(),
                "needs_revision": iteration < self.max_revisions  # ???? ?? ????????? ????????, ????????? ?????????
            }
    
    def is_final_iteration(self, task_id):
        """????????, ???????? ?? ???????? ?????????"""
        current_iteration = self.revision_counts.get(task_id, 0)
        return current_iteration >= self.max_revisions

# ??????? ??? ????????????
def test_critic():
    print("???????????? ??????-???????...")
    
    critic = CriticAgent()
    
    # ???????? ???????
    original_task = "??????? SEO-????? ????? example.com ? ???????? ???????????? ?? ?????????"
    
    # ???????? ????????? (????????? ? ??????????)
    test_result_poor = """
    SEO-????? ????? example.com
    
    ?? ????? ?????????? ????????? ????????:
    - ??????????? ????-????
    - ????????? ???????? ???????
    
    ????????????:
    1. ???????? ????-????
    2. ???????? ???????? ???????
    """
    
    # ???????? ????????? (???????)
    test_result_good = """
    # ?????? SEO-????? ????? example.com
    
    ## ??????????? ??????
    - ???????? ????????: 3.5 ??????? (????????? ???????????)
    - ????????? ??????: ???????????
    - SSL-??????????: ??????????
    - Robots.txt: ???????? ?????????
    - Sitemap.xml: ???????????
    
    ## ?????? ????-?????
    - Title: ????????????, ?? ?? ????????????? (??????? ????????)
    - Description: ??????????? ?? 60% ???????
    - H1-H6: ????????? ?????????? ????????
    
    ## ?????????? ??????
    - ???????????? ????????: 85%
    - ????????? ???????? ????: ??????
    - ????????? ??????: ??????? ?????????
    
    ## ?????? ???????? ??????
    - ??????????: 156
    - ????????: ???????
    - ????????????: ??????
    
    ## ????????????
    1. ?????????????? ???????? ???????? ????? ?????? ??????????? ? ??????????? CSS/JS
    2. ??????????? ????????? ?????? ?????
    3. ???????? ? ?????????????? ????-???? ?? ???? ?????????
    4. ??????? ? ???????? Sitemap.xml
    5. ???????? ????????? ??????????
    6. ????????? ????????? ???????? ???? ? ????????
    7. ????????????????? ??????? ???????? ??????
    
    ## ?????????? ?????????
    1. ???????: ???????? ????????? ??????, ??????????? ????-?????
    2. ???????: ????????? ???????? ????????, ?????????? Sitemap.xml
    3. ??????: ?????? ??? ????????? ????????
    """
    
    # ???? ? ?????? ???????????
    print("\n=== ?????? ??????? ?????????? ===")
    result = critic.evaluate(original_task, test_result_poor, "SEO-????????", "test_task_1")
    print(json.dumps(result, ensure_ascii=False, indent=2))
    
    # ???? ? ??????? ???????????
    print("\n=== ?????? ???????? ?????????? ===")
    result = critic.evaluate(original_task, test_result_good, "SEO-????????", "test_task_2")
    print(json.dumps(result, ensure_ascii=False, indent=2))
    
    return "???????????? ?????????"

if __name__ == "__main__":
    test_critic()
