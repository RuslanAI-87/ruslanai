import os
import json
import logging
import requests
import time
import sys
import shutil
import platform
import base64
from typing import Dict, Any, Optional, Union

# Verify Python version
if sys.version_info < (3, 9):
    raise RuntimeError("RuslanAI requires Python 3.9 or higher")

# Add project root to path for module imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

# Try importing memory system components
try:
    from central_agent.modules.memory import memory_system
    from central_agent.modules.notifications import notification_module
    MEMORY_SYSTEM_AVAILABLE = True
except ImportError:
    MEMORY_SYSTEM_AVAILABLE = False
    logging.warning("Memory system module unavailable. Functionality will be limited.")

# Ensure log directory exists
if not os.path.exists('logs'):
    os.makedirs('logs')

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("logs/codex_agent.log", mode='a'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger("codex_agent")

class CodexAgent:
    """
    Agent responsible for orchestrating code execution tasks in the RuslanAI system.
    Acts as an interface between the central orchestrator and the Cloud Function executor.
    """
    
    def __init__(self):
        """Initialize the CodexAgent with configuration from environment variables."""
        # Check dependencies
        self._check_dependencies()
        
        # Check disk space
        self._check_disk_space()
        
        # Load environment variables from .env file
        self._load_env_vars()
        
        # Required environment variables
        self.code_executor_url = os.getenv("CODE_EXECUTOR_URL")
        self.openai_api_key = os.getenv("OPENAI_API_KEY")
        self.anthropic_api_key = os.getenv("ANTHROPIC_API_KEY")
        
        # Validate required configuration
        if not self.code_executor_url:
            raise ValueError("CODE_EXECUTOR_URL environment variable is required")
        if not self.openai_api_key:
            logger.warning("OPENAI_API_KEY not set. OpenAI API calls will not be available.")
        if not self.anthropic_api_key:
            logger.warning("ANTHROPIC_API_KEY not set. Claude API calls will not be available.")
        
        # Optional configuration with defaults
        self.execution_timeout = int(os.getenv("EXECUTION_TIMEOUT", "180"))  # seconds
        self.openai_model = os.getenv("OPENAI_MODEL", "gpt-4.1")  # Updated to latest version
        
        # Initialize memory system
        self.memory = None
        if MEMORY_SYSTEM_AVAILABLE:
            try:
                self.memory = memory_system.MemorySystem()
                logger.info("Memory system connected successfully")
            except Exception as e:
                logger.error(f"Memory system initialization error: {str(e)}")
        
        # Initialize notification system
        self.notification_system = None
        if 'notification_module' in globals():
            try:
                self.notification_system = notification_module.NotificationSystem()
                logger.info("Notification system connected successfully")
            except Exception as e:
                logger.error(f"Notification system initialization error: {str(e)}")
        
        # Initialize GitHub access
        self.github_access_available = self.init_github_access()
        if self.github_access_available:
            logger.info("GitHub direct access initialized successfully")
        
        logger.info("CodexAgent initialized successfully")
    
    def _check_dependencies(self):
        """Check if required dependencies are installed"""
        try:
            import numpy
            import requests
            # Check for vector storage dependencies
            try:
                import faiss
                logger.info("FAISS found - vector search capabilities available")
            except ImportError:
                logger.warning("FAISS not found - vector search will use alternative slower methods")
                
            try:
                import sentence_transformers
                logger.info("Sentence Transformers found - advanced text embedding available")
            except ImportError:
                logger.warning("Sentence Transformers not found - using basic embeddings")
                
        except ImportError as e:
            logger.error(f"Missing critical dependency: {str(e)}")
            logger.info("Installing missing dependencies...")
            os.system("pip install -r requirements.txt")
    
    def _check_disk_space(self):
        """Check if there is enough disk space for vector storage"""
        try:
            # Required disk space for vector storage in bytes (500MB)
            required_space = 500 * 1024 * 1024
            
            # Get free disk space
            if platform.system() == 'Windows':
                free_space = shutil.disk_usage('C:').free
            else:
                free_space = shutil.disk_usage('/').free
                
            if free_space < required_space:
                logger.warning(f"Low disk space: {free_space/1024/1024:.2f}MB available, recommended 500MB+")
            else:
                logger.info(f"Sufficient disk space available: {free_space/1024/1024:.2f}MB")
        except Exception as e:
            logger.error(f"Error checking disk space: {str(e)}")
    
    def _load_env_vars(self):
        """Load environment variables from .env file"""
        env_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), '.env')
        if os.path.exists(env_path):
            with open(env_path, 'r') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#'):
                        key, value = line.split('=', 1)
                        os.environ[key] = value
    
    def init_github_access(self):
        """Initialize GitHub access using environment token"""
        self.github_token = os.getenv("GITHUB_TOKEN")
        if not self.github_token:
            logger.warning("GITHUB_TOKEN not set. GitHub direct access will not be available.")
            return False
        return True
                        
    def execute_code(self, code: str, language: str = "python") -> Dict[str, Any]:
        """
        Send code to the Cloud Function for execution.
        
        Args:
            code: The code to execute
            language: The programming language (default: python)
            
        Returns:
            Dict containing execution results (success, output, error if any)
        """
        start_time = time.time()
        logger.info(f"Executing {language} code (length: {len(code)})")
        
        # Store execution context in memory if available
        if self.memory:
            memory_id = self.memory.store(
                content={"code": code, "language": language},
                metadata={"type": "code_execution", "timestamp": time.time()}
            )
            logger.info(f"Execution context stored in memory with ID: {memory_id}")
        
        # Send notification about task start
        if self.notification_system:
            self.notification_system.send_notification(
                notification_type="task_started",
                content=f"Started executing {language} code"
            )
        
        try:
            headers = {"Content-Type": "application/json"}
            payload = {
                "code": code,
                "language": language,
                "timeout": self.execution_timeout
            }
            
            response = requests.post(
                self.code_executor_url,
                headers=headers,
                json=payload,
                timeout=self.execution_timeout + 5  # Add buffer for network latency
            )
            
            # Check if request was successful
            response.raise_for_status()
            result = response.json()
            
            execution_time = time.time() - start_time
            logger.info(f"Code execution completed in {execution_time:.2f}s: success={result.get('success', False)}")
            
            # Store result in memory
            if self.memory and 'memory_id' in locals():
                self.memory.update(
                    memory_id,
                    {"result": result},
                    {"execution_time": execution_time}
                )
            
            # Send notification about completion
            if self.notification_system:
                if result.get('success', False):
                    self.notification_system.send_notification(
                        notification_type="task_completed",
                        content=f"Code execution completed successfully in {execution_time:.2f}s"
                    )
                else:
                    self.notification_system.send_notification(
                        notification_type="task_failed",
                        content=f"Code execution failed: {result.get('error', 'Unknown error')}"
                    )
            
            if not result.get('success', False):
                logger.warning(f"Code execution failed: {result.get('error', 'Unknown error')}")
            
            return result
            
        except requests.exceptions.RequestException as e:
            logger.error(f"Error sending code to executor: {str(e)}")
            
            # Send error notification
            if self.notification_system:
                self.notification_system.send_notification(
                    notification_type="error",
                    content=f"Error communicating with code execution service: {str(e)}"
                )
                
            return {
                "success": False,
                "error": f"Failed to communicate with code executor: {str(e)}",
                "output": None
            }
        except json.JSONDecodeError:
            logger.error("Failed to parse response from code executor")
            
            # Send error notification
            if self.notification_system:
                self.notification_system.send_notification(
                    notification_type="error",
                    content="Error parsing response from code execution service"
                )
                
            return {
                "success": False,
                "error": "Failed to parse response from code executor",
                "output": response.text if 'response' in locals() else None
            }
        except Exception as e:
            logger.error(f"Unexpected error during code execution: {str(e)}")
            
            # Send error notification
            if self.notification_system:
                self.notification_system.send_notification(
                    notification_type="error",
                    content=f"Unexpected error during code execution: {str(e)}"
                )
                
            return {
                "success": False,
                "error": f"Unexpected error: {str(e)}",
                "output": None
            }
    
    def review_code_with_claude(self, code: str, context: Optional[str] = None) -> Dict[str, Any]:
        """
        Send code to Claude API for review and improvement suggestions.
        
        Args:
            code: The code to review
            context: Optional context about the code/task
            
        Returns:
            Dict containing Claude's review and suggestions
        """
        if not self.anthropic_api_key:
            logger.error("Cannot review code with Claude: ANTHROPIC_API_KEY not set")
            return {
                "success": False,
                "error": "Claude API key not configured",
                "review": None
            }
        
        logger.info(f"Requesting code review from Claude (code length: {len(code)})")
        
        try:
            headers = {
                "Content-Type": "application/json",
                "X-API-Key": self.anthropic_api_key,
                "anthropic-version": "2023-06-01"
            }
            
            # Prepare prompt for Claude
            system_prompt = """You are a helpful code review assistant for the RuslanAI project. 
            Analyze the provided code for:
            1. Correctness and potential bugs
            2. Adherence to PEP8 style (for Python) or best practices
            3. Performance optimizations
            4. Security vulnerabilities
            5. Suggestions for improvement
            
            Provide specific, actionable feedback in a clear, structured format."""
            
            user_message = f"Please review the following code:\n\n```\n{code}\n```"
            if context:
                user_message = f"{context}\n\n{user_message}"
            
            payload = {
                "model": "claude-3-7-sonnet-20250219",  # Updated to latest Claude version
                "max_tokens": 4000,
                "temperature": 0.3,
                "system": system_prompt,
                "messages": [
                    {"role": "user", "content": user_message}
                ]
            }
            
            response = requests.post(
                "https://api.anthropic.com/v1/messages",
                headers=headers,
                json=payload,
                timeout=30
            )
            
            response.raise_for_status()
            result = response.json()
            
            if "content" in result and len(result["content"]) > 0:
                review_text = result["content"][0]["text"]
                logger.info("Received code review from Claude")
                
                # Store review in memory if available
                if self.memory:
                    memory_id = self.memory.store(
                        content={"code": code, "review": review_text},
                        metadata={"type": "code_review", "timestamp": time.time()}
                    )
                    logger.info(f"Code review stored in memory with ID: {memory_id}")
                
                return {
                    "success": True,
                    "review": review_text
                }
            else:
                logger.warning("Claude returned empty review")
                return {
                    "success": False,
                    "error": "Claude returned empty review",
                    "review": None
                }
                
        except requests.exceptions.RequestException as e:
            logger.error(f"Error communicating with Claude API: {str(e)}")
            return {
                "success": False,
                "error": f"Failed to communicate with Claude API: {str(e)}",
                "review": None
            }
        except Exception as e:
            logger.error(f"Unexpected error during Claude code review: {str(e)}")
            return {
                "success": False,
                "error": f"Unexpected error: {str(e)}",
                "review": None
            }
    
    def handle_task(self, task: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process a complete task from the orchestrator.
        
        Args:
            task: A dictionary containing task information:
                - type: task type (e.g., "code_execution", "code_review")
                - code: the code to execute or review
                - language: the programming language
                - context: additional context (optional)
                
        Returns:
            Dict containing task results
        """
        task_type = task.get("type", "code_execution")
        code = task.get("code", "")
        language = task.get("language", "python")
        context = task.get("context", None)
        
        logger.info(f"Handling task of type: {task_type}")
        
        # Store task in memory if available
        if self.memory:
            memory_id = self.memory.store(
                content=task,
                metadata={"type": "task", "task_type": task_type, "timestamp": time.time()}
            )
            logger.info(f"Task stored in memory with ID: {memory_id}")
        
        results = {"task_type": task_type}
        
        if task_type == "code_execution":
            execution_result = self.execute_code(code, language)
            results["execution"] = execution_result
            
            # If execution failed and Claude is available, get review and suggestions
            if not execution_result.get("success", False) and self.anthropic_api_key:
                error_context = f"The following code failed with error: {execution_result.get('error', 'Unknown error')}"
                review_result = self.review_code_with_claude(code, error_context)
                results["review"] = review_result
                
        elif task_type == "code_review":
            review_result = self.review_code_with_claude(code, context)
            results["review"] = review_result
            
        elif task_type == "memory_search":
            query = task.get("query", "")
            if self.memory and hasattr(self.memory, 'search'):
                search_results = self.memory.search(query=query, limit=10)
                results["search_results"] = search_results
            else:
                results["error"] = "Memory search unavailable"
                logger.warning("Memory search requested but unavailable")
                
        else:
            logger.warning(f"Unknown task type: {task_type}")
            results["error"] = f"Unknown task type: {task_type}"
            
        # Store results in memory if available
        if self.memory and 'memory_id' in locals():
            self.memory.update(
                memory_id,
                {"results": results},
                {"completed": True, "completion_time": time.time()}
            )
            
        return results

    def find_similar_code(self, code_snippet: str, limit: int = 5) -> list:
        """
        Find similar code in memory based on semantic similarity.
        
        Args:
            code_snippet: Code snippet to search for
            limit: Maximum number of results
            
        Returns:
            List containing found similar code snippets
        """
        if not self.memory or not hasattr(self.memory, 'search'):
            logger.warning("Vector memory system unavailable for searching")
            return []
            
        try:
            results = self.memory.search(
                query=code_snippet,
                filter={"type": "code_execution"},
                limit=limit
            )
            return results
        except Exception as e:
            logger.error(f"Error searching for similar code: {str(e)}")
            return []

    def get_related_tasks(self, task_id: str) -> list:
        """
        Get related tasks based on task ID.
        
        Args:
            task_id: Task identifier
            
        Returns:
            List containing related tasks
        """
        if not self.memory or not hasattr(self.memory, 'get_related'):
            logger.warning("Related task search function unavailable")
            return []
            
        try:
            results = self.memory.get_related(task_id)
            return results
        except Exception as e:
            logger.error(f"Error getting related tasks: {str(e)}")
            return []
    
    def analyze_code_structure(self, code: str) -> Dict[str, Any]:
        """
        Analyze code structure to identify components, dependencies, and patterns.
        
        Args:
            code: Code to analyze
            
        Returns:
            Dict containing analysis results
        """
        try:
            # This is a placeholder for more advanced code analysis
            # In a real implementation, this would use AST parsing or other techniques
            
            # Simple structure analysis
            lines = code.split('\n')
            imports = [line for line in lines if line.strip().startswith('import') or 'from ' in line and ' import ' in line]
            functions = [line for line in lines if line.strip().startswith('def ')]
            classes = [line for line in lines if line.strip().startswith('class ')]
            
            return {
                "success": True,
                "stats": {
                    "total_lines": len(lines),
                    "import_count": len(imports),
                    "function_count": len(functions),
                    "class_count": len(classes)
                },
                "imports": imports,
                "functions": functions,
                "classes": classes
            }
        except Exception as e:
            logger.error(f"Error analyzing code structure: {str(e)}")
            return {
                "success": False,
                "error": f"Error analyzing code: {str(e)}"
            }
            
    def commit_changes(self, file_path: str, content: str, commit_message: str) -> Dict[str, Any]:
        """
        Commit changes to GitHub repository directly.
        
        Args:
            file_path: Path to the file in the repository
            content: New content for the file
            commit_message: Commit message
            
        Returns:
            Dict containing commit result information
        """
        if not self.github_token:
            return {"success": False, "error": "GitHub token not configured"}
            
        try:
            repo_name = "RuslanAI-87/ruslanai"  # Your repository name
            url = f"https://api.github.com/repos/{repo_name}/contents/{file_path}"
            
            # First get the current file to obtain the SHA
            headers = {
                "Authorization": f"token {self.github_token}",
                "Accept": "application/vnd.github.v3+json"
            }
            
            # Get current file (if exists)
            response = requests.get(url, headers=headers)
            
            if response.status_code == 200:
                # File exists, get its SHA
                current_file = response.json()
                sha = current_file["sha"]
                
                # Update file
                payload = {
                    "message": commit_message,
                    "content": base64.b64encode(content.encode()).decode(),
                    "sha": sha
                }
            else:
                # File doesn't exist, create new
                payload = {
                    "message": commit_message,
                    "content": base64.b64encode(content.encode()).decode()
                }
                
            # Make the commit
            response = requests.put(url, headers=headers, json=payload)
            response.raise_for_status()
            
            logger.info(f"Successfully committed changes to {file_path}")
            return {
                "success": True,
                "commit_url": response.json()["commit"]["html_url"]
            }
                
        except Exception as e:
            logger.error(f"Error committing to GitHub: {str(e)}")
            return {
                "success": False,
                "error": f"Failed to commit to GitHub: {str(e)}"
            }


# Example usage
if __name__ == "__main__":
    # This section runs when the script is executed directly
    agent = CodexAgent()
    
    # Example task: simple code execution
    sample_code = """
def fibonacci(n):
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fibonacci(n-1) + fibonacci(n-2)
    
# Test the function
print(fibonacci(10))
"""
    
    # Example 1: Execute code
    print("\n--- Example 1: Code Execution ---")
    result = agent.execute_code(sample_code)
    print(json.dumps(result, indent=2))
    
    # Example 2: Code review with Claude (if API key is configured)
    if agent.anthropic_api_key:
        print("\n--- Example 2: Code Review with Claude ---")
        review_result = agent.review_code_with_claude(sample_code, "This is a recursive Fibonacci implementation.")
        print(json.dumps(review_result, indent=2))
