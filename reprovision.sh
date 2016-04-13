
# Paste this inside your vm

sudo apt-get install python3-pip

pip3 install internetarchive
pip install internetarchive

pip install jupyter
pip3 install jupyter

python3 -m ipykernel install --user


wget -nc -O /texts/MedicalHeritage.ipynb https://raw.githubusercontent.com/heidiknoblauch/medicalheritagelibrary/master/MedicalHeritage.ipynb

echo '#!/bin/bash' > jupyter
echo '/home/vagrant/.local/bin/jupyter notebook --no-browser --ip=0.0.0.0 --notebook-dir /texts' > jupyter
sudo chmod 777 jupyter
sudo mv jupyter /usr/local/bin

# NOW go to localhost:8888 on your web browser

