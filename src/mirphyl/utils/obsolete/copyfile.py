#! /usr/bin/env python
'''
Created on Jul 19, 2011

@author: smirarab
'''
import sys
from shutil import copyfile

if __name__ == '__main__':
    from_path = sys.argv[1]
    to = sys.argv[2]

    copyfile(from_path, to)
    
