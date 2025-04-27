
#!/bin/sh

# Script to install required Python packages
echo "Installing PyTorch with CPU-only version..."
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

echo "Installing matplotlib..."
pip3 install matplotlib

echo "Installing tqdm..."
pip3 install tqdm

echo "Installing pyyaml..."
pip3 install pyyaml

echo "Installing requests..."
pip install requests

echo "Installing psutil..."
pip3 install psutil

echo "All packages installed successfully!"
