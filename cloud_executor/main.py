import subprocess
import functions_framework
from flask import Request

@functions_framework.http
def execute_code(request: Request):
    data = request.get_json(silent=True)
    code = data.get("code", "")

    with open("/tmp/code.py", "w") as f:
        f.write(code)

    try:
        result = subprocess.check_output(["python3", "/tmp/code.py"], stderr=subprocess.STDOUT, timeout=10)
        return {"success": True, "output": result.decode()}
    except subprocess.CalledProcessError as e:
        return {"success": False, "error": e.output.decode()}
    except subprocess.TimeoutExpired:
        return {"success": False, "error": "Execution timed out"}
