@echo off
cd /d C:\RuslanAI
echo Installing vector storage optimizations...

REM Установка pymilvus для высокопроизводительного векторного хранилища
echo Installing pymilvus...
pip install pymilvus==2.3.0

REM Установка FAISS GPU для векторных операций с использованием GPU
echo Installing FAISS with GPU support...
pip install faiss-gpu

REM Проверка доступности GPU через PyTorch
echo Checking GPU availability...
python -c "import torch; print('CUDA available:', torch.cuda.is_available()); print('GPU count:', torch.cuda.device_count()); print('GPU name:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'No GPU')"

echo.
echo Installation completed. 
echo Please run test_gpu_availability.py to verify that GPU is properly configured.
pause