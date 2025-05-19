# RuslanAI Encoding Monitoring and Diagnostics System

## Overview

This document describes the comprehensive encoding monitoring and diagnostics system developed for RuslanAI. The system provides tools for real-time monitoring, diagnostics, automatic fixing, and visualization of encoding issues, with a focus on proper handling of Cyrillic characters.

## System Components

The encoding monitoring and diagnostics system consists of the following main components:

1. **EncodingMonitor** - Real-time monitoring of encoding issues in logs and data transmission
2. **EncodingDiagnostics** - Tools for analyzing project files and detecting encoding inconsistencies
3. **EncodingFixer** - Automatic detection and fixing of encoding issues
4. **EncodingDashboard** - Web interface for visualizing statistics and diagnostics

These components work together with the previously developed EncodingManager to provide a complete solution for handling encoding issues in the RuslanAI project.

## Installation and Setup

### Prerequisites

- Python 3.7 or higher
- Required Python packages:
  - Flask (for the dashboard)
  - websockets (for WebSocket monitoring)
  - requests (for API monitoring)

### Installation

```bash
# Install required packages
pip install flask websockets requests

# Clone or copy the encoding system files to your project
cp encoding_*.py /path/to/your/project/
```

### Basic Setup

1. Ensure all component files are in your project's scripts directory:
   - `encoding_manager.py` - Core encoding management
   - `encoding_monitor.py` - Real-time monitoring
   - `encoding_diagnostics.py` - Diagnostics tools
   - `encoding_fixer.py` - Automatic fixing
   - `encoding_dashboard.py` - Web visualization

2. Import and use the components in your project as needed:

```python
from encoding_manager import EncodingManager
from encoding_monitor import EncodingMonitor
from encoding_diagnostics import EncodingDiagnostics
from encoding_fixer import EncodingFixer
```

## Component: EncodingMonitor

The EncodingMonitor provides real-time monitoring of encoding issues by analyzing logs and monitoring data transmission.

### Key Features

- Log file analysis for encoding issues
- Real-time monitoring of message transmission (WebSocket, API)
- Statistical reporting of encoding issues
- Alerting when issues exceed thresholds

### Usage Example

```python
from encoding_monitor import EncodingMonitor

# Create a monitor with log paths to check
monitor = EncodingMonitor(
    log_paths=['/path/to/logs/api.log', '/path/to/logs/websocket.log'],
    alert_threshold=5,  # Alert after 5 issues in quick succession
    check_interval=60   # Check logs every 60 seconds
)

# Register alert handlers
monitor.register_threshold_handler(lambda stats: print(f"Alert! {stats['total_issues_found']} issues detected!"))
monitor.register_issue_handler(lambda issue: print(f"Issue: {issue['type']} in {issue['component']}"))

# Start monitoring
monitor.start_monitoring()

# Add a message to monitor (e.g., from WebSocket)
monitor.add_message_to_monitor(
    message="Текст с кириллицей",
    source="websocket",
    direction="outgoing"
)

# Get monitoring statistics
stats = monitor.get_statistics()
print(f"Total issues: {stats['total_issues_found']}")

# Stop monitoring when done
monitor.stop_monitoring()
```

### Configuration Options

- `log_paths`: List of log files to monitor
- `alert_threshold`: Number of issues before triggering an alert
- `check_interval`: Interval in seconds between log checks

## Component: EncodingDiagnostics

The EncodingDiagnostics provides tools for analyzing project files and detecting encoding inconsistencies.

### Key Features

- Analysis of project files for encoding issues
- Detection of BOM markers and inconsistent encodings
- Line ending standardization checks
- Comprehensive reporting with recommendations

### Usage Example

```python
from encoding_diagnostics import EncodingDiagnostics

# Create a diagnostics instance
diagnostics = EncodingDiagnostics()

# Analyze a project directory
results = diagnostics.analyze_project(
    root_dir='/path/to/project',
    exclude_dirs=['node_modules', 'venv', '.git'],
    exclude_patterns=[r'\.pyc$', r'\.min\.js$']
)

# Generate a report
report = diagnostics.generate_report('/path/to/report.txt')

# Analyze a specific file
file_result = diagnostics.analyze_file('/path/to/file.py')
print(f"File encoding: {file_result['encoding']}")
print(f"Has BOM marker: {file_result['has_bom']}")
print(f"Has issues: {len(file_result['encoding_issues']) > 0}")

# Export results to JSON
diagnostics.export_results('/path/to/diagnostics.json')
```

### Analysis Capabilities

- Detection of file encodings (UTF-8, UTF-8 with BOM, Windows-1251, etc.)
- Identification of mixed line endings (CRLF, LF, CR)
- Detection of replacement characters and encoding mismatches
- Component-specific tests for API, WebSocket, etc.

## Component: EncodingFixer

The EncodingFixer provides tools for automatically detecting and fixing encoding issues.

### Key Features

- Automatic detection and repair of encoding issues in files
- Recovery of data from incorrectly encoded files and strings
- Batch processing of files and directories
- Backup creation before modification

### Usage Example

```python
from encoding_fixer import EncodingFixer

# Create a fixer instance
fixer = EncodingFixer()

# Fix a single file
result = fixer.fix_file(
    file_path='/path/to/file.py',
    target_encoding='utf-8',
    create_backup=True
)
print(f"File fixed: {result['success']}")

# Fix a string with encoding issues
fixed = fixer.fix_string('Текст с проблемой кодировки �')
print(f"Fixed text: {fixed['fixed_text']}")

# Fix JSON data with encoding issues
fixed_json = fixer.fix_json('{"message": "Сообщение с проблемой �"}')
print(f"Fixed JSON: {fixed_json['fixed_json']}")

# Batch fix files in a directory
batch_result = fixer.batch_fix_files(
    directory='/path/to/directory',
    file_patterns=['*.py', '*.txt'],
    target_encoding='utf-8',
    recursive=True,
    create_backup=True,
    dry_run=False
)
print(f"Files fixed: {batch_result['files_fixed']}")

# Fix an entire project
project_result = fixer.fix_project(
    project_dir='/path/to/project',
    target_encoding='utf-8',
    create_backup=True,
    exclude_dirs=['node_modules', 'venv', '.git'],
    dry_run=False
)
print(f"Project files fixed: {project_result['files_fixed']}")
```

### Fixing Capabilities

- Detection and repair of common mojibake patterns
- Recovery from encoding chain errors
- Fixing JSON Unicode escape sequences
- Handling of BOM markers
- Standardization of line endings

## Component: EncodingDashboard

The EncodingDashboard provides a web interface for visualizing encoding statistics and diagnostics.

### Key Features

- Real-time monitoring visualization
- Diagnostic report display
- Heat map of encoding issues by component
- Automatic fixing of issues through web interface

### Usage

```bash
# Run the dashboard
python encoding_dashboard.py

# Run with custom host and port
python encoding_dashboard.py --host 0.0.0.0 --port 8080

# Run without auto-opening browser
python encoding_dashboard.py --no-browser
```

The dashboard will open in your browser at http://localhost:5000 by default.

### Dashboard Features

- **Overview Tab**: Quick summary of system status and recent issues
- **Monitor Tab**: Detailed monitoring statistics and configuration
- **Diagnostics Tab**: Project analysis and detailed reports
- **Fixer Tab**: Tools for fixing encoding issues in files, strings, and projects

## Integration Points

### 1. API Server Integration

```python
from encoding_manager import EncodingManager
from encoding_monitor import EncodingMonitor

# Create instances
encoding_manager = EncodingManager()
monitor = EncodingMonitor()

# In your FastAPI endpoint
@app.post("/api/endpoint")
async def endpoint(request: Request):
    # Get request body
    body = await request.body()
    
    # Process with encoding management
    encoding = encoding_manager.detect_encoding(body)
    text = body.decode(encoding)
    
    # Add to monitoring
    monitor.add_message_to_monitor(text, "api", "incoming")
    
    # Process request...
    
    # Create response with proper encoding
    response_data = {"message": "Ответ с кириллицей"}
    response_json = encoding_manager.json_dumps(response_data, ensure_ascii=False)
    
    # Add outgoing message to monitoring
    monitor.add_message_to_monitor(response_data, "api", "outgoing")
    
    return Response(
        content=response_json,
        media_type="application/json",
        headers={"Content-Type": "application/json; charset=utf-8"}
    )
```

### 2. WebSocket Integration

```python
from encoding_manager import EncodingManager
from encoding_monitor import EncodingMonitor

# Create instances
encoding_manager = EncodingManager()
monitor = EncodingMonitor()

# In your WebSocket handler
async def websocket_handler(websocket, path):
    try:
        async for message in websocket:
            # Add incoming message to monitoring
            monitor.add_message_to_monitor(message, "websocket", "incoming")
            
            # Process message with encoding management
            if isinstance(message, bytes):
                encoding = encoding_manager.detect_encoding(message)
                text = message.decode(encoding)
                data = encoding_manager.json_loads(text)
            else:
                data = encoding_manager.json_loads(message)
            
            # Create response
            response = {"status": "ok", "message": "Ответ с кириллицей"}
            response_json = encoding_manager.json_dumps(response, ensure_ascii=False)
            
            # Add outgoing message to monitoring
            monitor.add_message_to_monitor(response, "websocket", "outgoing")
            
            # Send response
            await websocket.send(response_json)
    except Exception as e:
        # Log encoding-related exceptions
        if "codec" in str(e) or "encoding" in str(e):
            monitor.add_message_to_monitor(
                {"error": str(e)},
                "websocket",
                "error"
            )
```

### 3. File Operations Integration

```python
from encoding_manager import EncodingManager
from encoding_monitor import EncodingMonitor

# Create instances
encoding_manager = EncodingManager()
monitor = EncodingMonitor()

# Reading configuration files
def load_config(config_path):
    try:
        content = encoding_manager.read_file(config_path)
        return encoding_manager.json_loads(content)
    except Exception as e:
        monitor.add_message_to_monitor(
            {"error": str(e), "path": config_path},
            "file_io",
            "error"
        )
        return {}

# Writing log files
def write_log(log_path, log_entry):
    try:
        # Get existing content
        content = ""
        if os.path.exists(log_path):
            content = encoding_manager.read_file(log_path)
        
        # Append new entry
        content += log_entry + "\n"
        
        # Write back
        encoding_manager.write_file(log_path, content, encoding='utf-8')
    except Exception as e:
        monitor.add_message_to_monitor(
            {"error": str(e), "path": log_path},
            "file_io",
            "error"
        )
```

## Best Practices

### 1. Monitoring Configuration

- Configure log paths based on your project structure
- Set alert thresholds appropriate for your project's volume
- Register custom alert handlers for notifications (email, Slack, etc.)
- Use a structured logging format in your application for better parsing

### 2. Diagnostics Usage

- Run diagnostics regularly, especially after code changes
- Standardize on UTF-8 without BOM for all text files
- Standardize line endings (LF recommended for cross-platform compatibility)
- Address identified encoding issues promptly to prevent cascading problems

### 3. Fixer Usage

- Always create backups before applying automatic fixes
- Use dry-run mode first to preview changes
- Fix issues in libraries and utility functions first, then application code
- Be cautious when fixing encoded database content

### 4. Dashboard Usage

- Use the dashboard for regular monitoring of system health
- Set up daily or weekly diagnostics reports
- Establish encoding health metrics for your project
- Train team members on identifying and addressing encoding issues

## Troubleshooting

### Common Issues and Solutions

1. **Mojibake (Garbled Text)**
   - Symptom: Text appears as "РџСЂРёРІРµС‚" instead of "Привет"
   - Cause: UTF-8 text interpreted as Windows-1251 or vice versa
   - Solution: Use EncodingFixer.fix_string() with appropriate parameters

2. **Replacement Characters (�)**
   - Symptom: Text contains � characters
   - Cause: Characters could not be represented in the chosen encoding
   - Solution: Identify the correct source encoding with EncodingDiagnostics

3. **BOM Marker Issues**
   - Symptom: Files start with invisible characters that cause parsing issues
   - Cause: UTF-8 BOM markers (EF BB BF) at the start of files
   - Solution: Use EncodingFixer.fix_file() with target_encoding='utf-8'

4. **Different Behaviors on Different Systems**
   - Symptom: Code works on Windows but fails on Linux or vice versa
   - Cause: Often due to line ending differences or system-specific encodings
   - Solution: Standardize line endings and use explicit encoding in all file operations

## Advanced Topics

### Custom Encoding Chain Recovery

For specialized recovery needs, you can create custom encoding chains:

```python
from encoding_fixer import EncodingFixer

fixer = EncodingFixer()

# Define a custom recovery function
def custom_recovery(text):
    # Example: Recover from triple encoding error
    # Text was UTF-8 -> Windows-1251 -> UTF-8 -> Windows-1251
    try:
        # First decode as if it's Windows-1251
        bytes_1 = text.encode('windows-1251')
        
        # Then as if it's UTF-8
        text_2 = bytes_1.decode('utf-8')
        
        # Then repeat
        bytes_3 = text_2.encode('windows-1251')
        text_4 = bytes_3.decode('utf-8')
        
        return text_4
    except Exception:
        return text

# Test with problematic text
problematic = "Ð¢ÐµÐºÑÑ Ñ Ð¿Ñ€Ð¾Ð±Ð»ÐµÐ¼Ð¾Ð¹"
recovered = custom_recovery(problematic)
print(f"Recovered: {recovered}")
```

### Creating Custom Monitoring Alerts

You can integrate the monitoring system with your organization's alerting infrastructure:

```python
from encoding_monitor import EncodingMonitor
import requests

def slack_alert_handler(stats):
    """Send an alert to Slack when encoding issues exceed threshold"""
    webhook_url = "https://hooks.slack.com/services/your/webhook/url"
    
    message = {
        "text": f"🚨 Encoding Alert: {stats['total_issues_found']} issues detected!",
        "blocks": [
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*Encoding Alert*\n{stats['total_issues_found']} issues detected in the last {stats.get('monitoring_duration_seconds', 0)/60:.1f} minutes."
                }
            },
            {
                "type": "section",
                "fields": [
                    {"type": "mrkdwn", "text": f"*Issues per hour:*\n{stats.get('issues_per_hour', 0):.2f}"},
                    {"type": "mrkdwn", "text": f"*Most affected component:*\n{max(stats.get('issues_by_component', {}).items(), key=lambda x: x[1])[0] if stats.get('issues_by_component') else 'None'}"}
                ]
            }
        ]
    }
    
    requests.post(webhook_url, json=message)

# Register the custom handler
monitor = EncodingMonitor()
monitor.register_threshold_handler(slack_alert_handler)
```

### Custom File Type Analysis

You can extend the diagnostics to handle specialized file formats:

```python
from encoding_diagnostics import EncodingDiagnostics

# Extend the EncodingDiagnostics class
class CustomEncodingDiagnostics(EncodingDiagnostics):
    def analyze_xml_file(self, file_path):
        """Special handling for XML files with encoding declarations"""
        result = self.analyze_file(file_path)
        
        # Additional XML-specific checks
        with open(file_path, 'rb') as f:
            content_bytes = f.read(1000)  # Read first 1000 bytes
            
            # Check for XML declaration
            xml_decl_match = re.search(b'<\\?xml.*encoding=["\'](.*?)["\']', content_bytes)
            if xml_decl_match:
                declared_encoding = xml_decl_match.group(1).decode('ascii').lower()
                actual_encoding = result['encoding'].lower()
                
                if declared_encoding != actual_encoding:
                    result['encoding_issues'].append(
                        f"XML declares encoding as {declared_encoding} but actual encoding is {actual_encoding}"
                    )
        
        return result
```

## Contributing

### Adding New Encodings Support

To add support for a new encoding:

1. Update the detection logic in `EncodingManager.detect_encoding()`
2. Add appropriate recovery chains in `EncodingFixer.ENCODING_CHAINS`
3. Add test patterns in `EncodingDiagnostics.TEST_PATTERNS`
4. Update the dashboard to show statistics for the new encoding

### Adding New Components

To add monitoring support for a new component:

1. Create an adapter that integrates with the EncodingManager
2. Add monitoring calls in the component's input/output handling
3. Update the diagnostics to include component-specific tests
4. Extend the dashboard to display the new component's statistics

## Conclusion

The RuslanAI Encoding Monitoring and Diagnostics System provides a comprehensive solution for managing character encodings, with a focus on Cyrillic support. By integrating these tools into your development and operational workflows, you can significantly reduce encoding-related issues and improve the quality and reliability of your application.