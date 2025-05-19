# В класс CodexAgent добавьте следующие методы:

def init_github_access(self):
    """Initialize GitHub access using environment token"""
    self.github_token = os.getenv("GITHUB_TOKEN")
    if not self.github_token:
        logger.warning("GITHUB_TOKEN not set. GitHub direct access will not be available.")
        return False
    return True

def commit_changes(self, file_path, content, commit_message):
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
