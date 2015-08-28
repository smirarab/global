''' 1. Configures the environment for running experiments'''

import ConfigParser
import os
from glob import glob

CONFIG_FILE = "%s/global.conf" %__path__[0]

config = ConfigParser.ConfigParser()
config.readfp(open(CONFIG_FILE))

HOME = config.get("DEFAULT", "home")
WS_HOME = os.environ.get('WS_HOME',config.get("DEFAULT", "ws-home"))
WS_HOME = os.environ.get('WS_HOME')

#tools_options = config.options("tools")

def get_tool_path(tool_name, ver='*'):
    if ver == '*':
        ver = config.get("tools", "%s.def" % tool_name)
    return config.get("tools", "%s.%s" % (tool_name, ver))

def get_datasets(dataset_name, filter="*"):
    ds_path = config.get("datasets", dataset_name)
    datasets=[]
    for f in filter.split(","): datasets.extend(glob("%s/%s" % (ds_path, f)))
    replicas_st = config.get("datasets", "%s.replicas" % dataset_name)
    replicas_st = replicas_st.split(",")
    replicas = []
    for s in replicas_st:
        replicas.extend(range(int(s[0:s.find(":")]), int(s[s.rfind(":") + 1:])) if s.find(":") > -1  else [int(s)])
    replicas.sort()
    print replicas
    names = config.get("datasets", "%s.names" % dataset_name).split(",")
    outgroups = config.get("datasets", "%s.outgroup" % dataset_name)
    options = config.get("datasets", "%s.options" % dataset_name).split(",") if config.has_option("datasets", "%s.options" % dataset_name) else []
    return datasets, replicas , names, outgroups, options
