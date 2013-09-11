''' 1. Configures the environment for running experiments'''

import ConfigParser
import os
from glob import glob

print __path__
CONFIG_FILE = "%s/global.conf" %__path__[0]

config = ConfigParser.ConfigParser()
config.readfp(open(CONFIG_FILE))

HOME = config.get("DEFAULT", "home")
WS_HOME = config.get("DEFAULT", "ws-home")
#tools_options = config.options("tools")

def get_tool_path(tool_name, ver='*'):
    if ver == '*':
        ver = config.get("tools", "%s.def" % tool_name)
    return config.get("tools", "%s.%s" % (tool_name, ver))

def get_datasets(dataset_name, filter="*"):
    ds_path = config.get("datasets", dataset_name)
    datasets = glob("%s/%s" % (ds_path, filter))
    replicas_st = config.get("datasets", "%s.replicas" % dataset_name)
    replicas_st = replicas_st.split(",")
    replicas = []
    for s in replicas_st:
        replicas.extend(range(int(s[0:s.find(":")]), int(s[s.rfind(":") + 1:])) if s.find(":") > -1  else [int(s)])
    replicas.sort()
    return datasets, replicas 
