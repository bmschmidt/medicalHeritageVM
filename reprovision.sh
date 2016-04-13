#!/bin/bash


# Paste this inside your vm

wget -nc heidis-notebook.ipynb
pip install internetarchive

mv heidis-notebook.ipynb /texts/
sudo service ipython-notebook start

# NOW go to localhost:8888 on your web browser
