$agentsMdContent = @'
# RuslanAI Agents Guide

## Project Overview
RuslanAI is a sophisticated multi-agent AI platform designed for coordinating various AI components through a central orchestrator. The system features a WebSocket-based communication layer for real-time bidirectional interaction, a vector memory system for context retention, and a web interface for control.

## Architecture
- Central Orchestrator (`central_orchestrator.py`) - Core component that coordinates all agents
- API Server (`encoding_fixed_api.py`) - Handles HTTP requests from the user interface
- WebSocket Server (`simple_ws_server.py`) - Provides bidirectional communication
- Memory System - Multi-level context storage and processing
- Specialized Agents - Autonomous components for specific tasks

## Code Style & Standards
- Follow PEP8 for all Python code
- Use snake_case for Python variables, functions, and file names
- Each function must include docstring documentation
- Utilize type hints for function parameters and return values
- Log all significant operations using the standard logging module
- Handle exceptions appropriately with detailed error messages

## Development Guidelines
- Maintain backward compatibility with existing agent interfaces
- Add comprehensive unit tests for new features
- Optimize code for performance, especially memory system operations
- Document API changes in code comments
- Ensure proper error handling and recovery mechanisms

## Working with the Memory System
The memory system uses a multi-level architecture:
- Short-term memory: Current session context
- Long-term memory: Vector embeddings for semantic search
- Hierarchical organization: Summary, context, and detail levels

When modifying memory components, pay special attention to:
- Thread safety in asynchronous operations
- Efficient vector storage access patterns
- Memory leak prevention in long-running processes

## Integration Points
- Central orchestrator connects to all agents through standardized interfaces
- WebSocket server maintains client connections and routes messages
- Memory system integrates with vector databases for efficient retrieval
- Code execution module uses Cloud Function for isolated execution

## Environment Requirements
Required environment variables:
- CODE_EXECUTOR_URL: URL for Cloud Function executor
- OPENAI_API_KEY: Access key for OpenAI API (GPT-4.1)
- ANTHROPIC_API_KEY: Access key for Anthropic API (Claude 3.7 Sonnet)
- EXECUTION_TIMEOUT: Timeout value for code execution in seconds

The system requires Python 3.9+ and dependencies listed in requirements.txt.
'@

$agentsMdContent | Out-File -FilePath "C:\RuslanAI\AGENTS.md" -Encoding utf8
Write-Host "Файл AGENTS.md успешно создан"
