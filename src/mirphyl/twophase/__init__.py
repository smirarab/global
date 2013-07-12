from mirphyl.setup import get_tool_path, get_datasets
import ConfigParser
import os

CONFPATH = __path__[0]
twophase_conf = ConfigParser.SafeConfigParser()
twophase_conf.readfp(open(os.path.join(CONFPATH,"twophase.conf")))

mltools = twophase_conf.options("ML")
algtools = twophase_conf.options("alignment")

datasets = twophase_conf.options("datasets")

        
