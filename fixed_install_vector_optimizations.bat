@echo off
cd /d C:\RuslanAI
echo Installing vector storage optimizations...

REM Установка правильной версии PyTorch с поддержкой CUDA
echo Installing PyTorch with CUDA support...
pip uninstall -y torch torchvision torchaudio
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

REM Установка pymilvus с совместимыми зависимостями
echo Installing pymilvus with compatible dependencies...
pip uninstall -y pymilvus grpcio
pip install grpcio>=1.58.0
pip install pymilvus==2.3.4

REM Установка FAISS CPU (поскольку GPU версия недоступна для Windows напрямую)
echo Installing FAISS CPU...
pip install faiss-cpu

REM Проверка доступности GPU через PyTorch
echo Checking GPU availability...
python -c "import torch; print('CUDA available:', torch.cuda.is_available()); print('GPU count:', torch.cuda.device_count()); print('GPU name:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'No GPU')"

echo.
echo Installation completed. 
echo Please run test_gpu_availability.py to verify that GPU is properly configured.
pause