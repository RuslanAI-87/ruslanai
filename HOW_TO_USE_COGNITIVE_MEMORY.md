# How to Use Cognitive Memory System in RuslanAI

This guide explains how to enable and use the Cognitive Memory System in your RuslanAI application.

## Quick Start

### 1. Enable Cognitive Memory in Orchestrator

To enable cognitive memory in your existing application, update your orchestrator initialization:

```python
from central_orchestrator import CentralOrchestrator
from cognitive_memory_integration import update_orchestrator_memory_system

# Create orchestrator instance
orchestrator = CentralOrchestrator()

# Update with cognitive memory (API key is optional, used for LLM-based features)
orchestrator = update_orchestrator_memory_system(orchestrator, api_key="your_openai_api_key")
```

### 2. Use the Orchestrator Normally

Once enabled, the cognitive memory system works behind the scenes - no API changes required:

```python
# Start a conversation with a chat ID to enable persistence
response = orchestrator.start_session("Hello, I need help with a task", chat_id="user123")

# Continue the conversation
response = orchestrator.continue_conversation("Can you explain more about this?", chat_id="user123")
```

The `chat_id` is crucial for dialog persistence - it allows the system to restore conversations across sessions.

## Advanced Usage

### Direct Memory Access

For advanced applications, you can access the memory system directly:

```python
from cognitive_memory_system import CognitiveMemorySystem
from sentence_transformers import SentenceTransformer

# Initialize embedding model
embedding_model = SentenceTransformer("all-MiniLM-L6-v2")

# Create embedding service
class EmbeddingService:
    def __init__(self, model):
        self.model = model
        
    async def get_embedding(self, text):
        embedding = self.model.encode(text)
        return embedding.tolist()

embedding_service = EmbeddingService(embedding_model)

# Initialize the cognitive memory system
memory_system = CognitiveMemorySystem(
    embedding_service=embedding_service,
    vector_store_path="C:/RuslanAI/data/vector_store"
)

# Store information
memory_id = await memory_system.store(
    content="Important information to remember",
    metadata={"source": "user", "timestamp": "2025-05-17T12:00:00Z"},
    tags=["important", "user_info"],
    level="working"  # Can be: operational, working, long_term, meta
)

# Retrieve information 
results = await memory_system.retrieve(
    query="important information",
    limit=5
)

# Retrieve by tags
results = await memory_system.retrieve_by_tags(
    tags=["important"],
    limit=5
)

# Forget (delete) memory
await memory_system.forget(memory_id)
```

### Dialog Management

The cognitive memory system provides specialized functions for dialog management:

```python
# Save a dialog
chat_id = "user123"
dialog = [
    {"role": "human", "content": "Can you help me with a programming task?"},
    {"role": "ai", "content": "Of course! What kind of programming task do you need help with?"}
]

await memory_system.save_dialog(chat_id, dialog)

# Restore a dialog
restored_dialog = await memory_system.restore_dialog(chat_id)
```

## Memory Levels

The cognitive memory system uses four distinct memory levels:

1. **Operational** - Very short-term, for immediate context (3-5 dialog turns)
2. **Working** - Short to medium-term, for current session information
3. **Long-term** - Persistent storage for important information
4. **Meta** - System self-reflection and optimization data

When storing information, you can specify the level, or let the attention layer decide automatically.

## Cognitive Features

### Attention Management

The system automatically evaluates the importance of information:

```python
# Store with auto importance evaluation
memory_id = await memory_system.store(
    content="This might be important information",
    auto_evaluate=True  # Let the system determine importance
)
```

### Consistency Checking

The system detects and resolves contradictions:

```python
# Enable consistency checking when storing
memory_id = await memory_system.store(
    content="The capital of France is Paris",
    check_consistency=True  # Detect potential contradictions
)
```

### Compression & Summarization

Generate summaries of lengthy content:

```python
# Get a summary of stored information
summary = await memory_system.summarize(
    content_id=memory_id,
    level="concise"  # Options: concise, detailed, comprehensive
)
```

## Testing the System

Run the included test script to verify the system is working correctly:

```
python test_cognitive_memory.py
```

Or use the batch file:

```
test_cognitive_memory.bat
```

## Troubleshooting

### Missing Dependencies

If you encounter missing dependencies, install them with:

```
pip install sentence-transformers pymilvus langchain-openai openai
```

### Vector Store Issues

If the vector store isn't working:

1. Check that Milvus is installed and running
2. Verify the vector store path exists
3. Try with the `use_basic_storage=True` parameter to use a simpler storage method

### Performance Issues

If experiencing slow performance:

1. Consider using GPU acceleration for embeddings
2. Reduce the dimensionality of the vector embeddings
3. Implement more aggressive memory consolidation
4. Increase the operational memory size for frequent queries