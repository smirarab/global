'''
Created on Jul 20, 2011

@author: smirarab
'''
import os

def require_dir(path):
    if os.path.exists(path):
        return True
    else:
        os.makedirs(path)        