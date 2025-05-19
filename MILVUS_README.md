# Milvus Vector Database for RuslanAI

This folder contains scripts to install and run Milvus, a high-performance vector database optimized
for RuslanAI's cognitive memory system. This installation is specifically tuned for your hardware:
- NVIDIA RTX 4080
- 64GB RAM
- Intel Core Ultra 9 185H

## Quick Start

1. Install Milvus:
   ```
   ./install_milvus.sh
   ```

2. Start Milvus:
   ```
   ./milvus_control.sh start
   ```

3. Run performance test:
   ```
   ./milvus_control.sh test
   ```

4. Check status:
   ```
   ./milvus_control.sh status
   ```

5. Stop Milvus:
   ```
   ./milvus_control.sh stop
   ```

## Files

- `docker-compose.yml` - Docker Compose configuration for Milvus with optimized settings
- `milvus_config.py` - Python client configuration for connecting to Milvus
- `test_milvus.py` - Performance test script
- `milvus_vector_store.py` - Vector store adapter for RuslanAI memory system
- `integrate_milvus.py` - Integration patch for memory system
- `milvus_control.sh` - Control script to start/stop Milvus

## Optimization Notes

This Milvus installation has been optimized for:
- GPU-accelerated similarity search using your RTX 4080
- HNSW indexing for maximum performance
- Memory and CPU settings calibrated for your system
- High throughput and low latency queries

For advanced configuration, edit the `docker-compose.yml` file.
