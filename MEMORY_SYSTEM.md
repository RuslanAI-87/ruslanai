# RuslanAI Memory System

This document explains how the memory system works in RuslanAI, including the hierarchical memory architecture and vector storage.

## Overview

RuslanAI uses a multi-level memory system to maintain conversation context and provide relevant information to the AI. The system consists of:

1. **Hierarchical Memory** - Manages different memory levels
2. **Vector Storage** - Enables semantic search with optional GPU acceleration

## Hierarchical Memory

The memory system is organized into three distinct levels:

1. **Summary Level** - High-level information and important context
2. **Context Level** - Intermediate details needed for coherent conversations
3. **Detail Level** - Specific facts, references, and granular information

### Core Features

- **Memory Persistence** - Conversations are stored and can be retrieved later
- **Memory Optimization** - Less important information is gradually forgotten
- **Context Maintenance** - Keeps track of important context during conversations

## Vector Storage

The vector storage system provides semantic search capabilities:

- **Semantic Search** - Find relevant information based on meaning, not just keywords
- **GPU Acceleration** - Uses GPU (when available) to speed up vector computations
- **Fallback Mechanism** - Works even if advanced features aren't available

### Key Components

- **Embeddings** - Text is converted to vector representations using sentence-transformers
- **ChromaDB** - Vector database for efficient similarity search
- **Local Storage** - Fallback JSON-based storage when vector DB is unavailable

## Dependencies

The memory system requires the following Python libraries:

```
sentence-transformers
chromadb
torch
```

These can be installed using the provided `restart_api.bat` script.

## Usage

The memory system is automatically used by the API server. When sending requests to the API, conversations are stored and context is maintained between requests.

### Example Flow

1. User sends a message
2. Message is processed by the central orchestrator
3. Important information is stored in the memory system
4. When responding, the system retrieves relevant context from memory
5. Response is generated with awareness of conversation history

## Troubleshooting

If you encounter issues with the memory system:

1. Ensure all dependencies are installed
2. Check that file encoding is set to UTF-8
3. Verify that the data storage directory exists
4. Check logs in `C:/RuslanAI/logs/vector_store.log`

If you see the warning "Basic version with hashing will be used instead of vector embeddings", it means the advanced vector storage features couldn't be initialized. The system will still work but with reduced semantic search capabilities.

## Technical Architecture

```
memory_system.py - Core hierarchical memory implementation
vector_store.py - Vector-based semantic search with GPU acceleration
```

The vector store uses a combination of ChromaDB for vector search and a local JSON file for backup storage. If GPU acceleration is available, it's automatically used to speed up vector embeddings generation.