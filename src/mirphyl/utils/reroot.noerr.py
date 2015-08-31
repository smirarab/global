#!/usr/bin/env python

import reroot
import sys

try:
    reroot.main(sys.argv)
except KeyError as e:
    print e
    sys.exit(0)
