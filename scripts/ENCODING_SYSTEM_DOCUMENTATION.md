# RuslanAI Encoding System Documentation

## Overview

This document describes the comprehensive encoding system developed for RuslanAI, focusing on proper handling of Cyrillic characters throughout the application. The system addresses several interconnected issues related to character encodings, particularly UTF-8, UTF-8 with BOM, and Windows-1251 encodings.

## Key Components

The encoding system consists of the following main components:

1. **EncodingManager** - Core class providing centralized encoding functionality
2. **WebSocketEncodingAdapter** - Adapter for WebSocket communications
3. **APIEncodingAdapter** - Adapter for API requests and responses
4. **Client Implementations** - Examples of client-side encoding handling

## EncodingManager

The `EncodingManager` class serves as the central hub for all encoding-related operations, providing essential functionality:

- Detection of file encodings (UTF-8, UTF-8 with BOM, Windows-1251)
- File I/O with proper encoding handling
- JSON serialization and deserialization with Cyrillic support
- Text validation for encoding issues

### Key Methods

```python
# Detect encoding of byte data
encoding = EncodingManager.detect_encoding(content_bytes)

# Read a file with automatic encoding detection
content = EncodingManager.read_file(file_path)

# Write to a file with specified encoding
EncodingManager.write_file(file_path, content, encoding='utf-8', add_bom=False)

# Serialize to JSON with Cyrillic support
json_str = EncodingManager.json_dumps(data, ensure_ascii=False)

# Deserialize from JSON with Cyrillic support
data = EncodingManager.json_loads(json_str)

# Validate text for encoding issues
validation = EncodingManager.validate_text(text)
```

## WebSocket Encoding Support

The WebSocket encoding adapter ensures proper transmission of Cyrillic characters in WebSocket communications:

- Encodes messages (text, JSON, binary) for transmission
- Decodes incoming messages with proper encoding detection
- Provides middleware for easy integration with existing WebSocket code
- Collects statistics on encoding issues

### Integration Example

```python
# Server-side
@with_encoding
async def websocket_handler(websocket, path):
    # WebSocket connection is now encoding-aware
    data = await websocket.recv()  # Automatically handles encoding
    await websocket.send(response_data)  # Properly encodes response

# Client-side
async with websockets.connect(uri) as websocket:
    middleware = WebSocketEncodingMiddleware(websocket)
    
    # Use middleware for encoding-aware operations
    await middleware.send_json({"message": "Текст на русском"})
    response = await middleware.receive_json()
```

## API Encoding Support

The API encoding adapter ensures proper handling of Cyrillic characters in HTTP requests and responses:

- Processes request bodies with encoding detection
- Ensures proper content-type headers with charset specification
- Creates JSON responses with correct encoding
- Provides FastAPI middleware for automatic encoding handling

### Integration Example

```python
# Add middleware to FastAPI application
app = FastAPI()
encoding_adapter = add_encoding_middleware(app)

# Use adapter in endpoints
@app.post("/api/endpoint")
async def endpoint(request: Request):
    data = await encoding_adapter.process_request_body(request)
    # Process data...
    return encoding_adapter.create_json_response(response_data)
```

## Client Usage

The encoding-aware client demonstrates how to properly handle encodings when interacting with servers:

- Makes API requests with proper content-type headers
- Handles WebSocket communications with encoding support
- Manages configuration files with Cyrillic content
- Validates text for encoding issues

### Example

```python
client = EncodingAwareClient()

# Load configuration
config = client.load_config("config.json")

# Make API request
response = client.make_api_request("https://api.example.com/endpoint", {
    "query": "поиск по-русски"
})

# Connect to WebSocket
await client.connect_websocket("ws://example.com/ws", [
    "Сообщение на русском",
    {"command": "test", "text": "Тестовое сообщение"}
])
```

## Best Practices

1. **Always use EncodingManager for file operations**
   - Ensures consistent handling of encodings
   - Automatically detects BOM markers
   - Provides proper fallbacks

2. **Set explicit content-type headers with charset**
   - Use `Content-Type: application/json; charset=utf-8` for API responses
   - Ensures browsers and clients interpret data correctly

3. **Disable ASCII escaping in JSON**
   - Always use `ensure_ascii=False` with `json.dumps()`
   - Preserves Cyrillic characters in human-readable form

4. **Validate text before transmission**
   - Use `EncodingManager.validate_text()` to check for issues
   - Helps identify potential problems before they cause issues

5. **Use middleware for existing code**
   - Both API and WebSocket adapters provide middleware options
   - Allows adding encoding support without major code changes

## Implementation Plan

To fully integrate the encoding system:

1. **Install core components**
   - Add `encoding_manager.py` to your project
   - Install adapter modules as needed

2. **Update API server code**
   - Add EncodingMiddleware to FastAPI application
   - Use APIEncodingAdapter in endpoints

3. **Update WebSocket handlers**
   - Apply the `with_encoding` decorator to handlers
   - Or use WebSocketEncodingMiddleware directly

4. **Update client code**
   - Use EncodingManager for file operations
   - Set proper headers and encoding for API requests
   - Use WebSocketEncodingMiddleware for WebSocket communications

5. **Run diagnostics**
   - Use test tools to verify encoding handling
   - Check statistics for encoding issues

## Troubleshooting

Common issues and solutions:

1. **Question marks or boxes instead of Cyrillic characters**
   - Check content-type headers in API responses
   - Verify `ensure_ascii=False` is used with JSON serialization

2. **BOM markers in files causing parsing errors**
   - Use EncodingManager.read_file() which handles BOM detection
   - Use EncodingStandardizer to remove BOMs if needed

3. **Encoding errors in WebSocket communications**
   - Ensure WebSocketEncodingAdapter is used consistently
   - Check for mixing of string and bytes types

4. **ASCII escape sequences in JSON**
   - Check for `ensure_ascii=True` (default) in json.dumps() calls
   - Use EncodingManager.json_dumps() which sets ensure_ascii=False

## File Reference

- `encoding_manager.py` - Core encoding functionality
- `websocket_encoding_adapter.py` - WebSocket support
- `api_encoding_adapter.py` - API request/response support
- `client_encoding_example.py` - Client implementation examples
- `websocket_encoding_example.py` - WebSocket usage examples
- `test_encoding_system.py` - Comprehensive tests

## Contributors

- EncodingManager and adapters by Claude Code for RuslanAI