#!/usr/bin/env python

import ez_setup
ez_setup.use_setuptools()
from setuptools import setup, find_packages

setup(name='mirphyl',
      version='1.0',
      description='Python Environment for haphazard and poorly structured scripts',
      author='Siavash Mirarab',
      author_email='smirarab@gmail.com',
      packages=['mirphyl', 'mirphyl.setup','mirphyl.utils'],
      install_requires= ['dendropy>=3.12.0,<4.0'], 
      data_files= [('mirphyl/setup',['mirphyl/setup/global.conf'])],
      include_package_data = True
     )

