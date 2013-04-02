'''
Created on Jul 18, 2011

@author: smirarab

'''

from mirphyl.twophase import datasets, mltools, algtools, CONFPATH,\
    twophase_conf
from mirphyl.setup import get_datasets, get_tool_path, HOME
import sys
import os
from shutil import copyfile
from mirphyl.setup.utilities import require_dir

IGNORE_MISSING_OPTIONAL_FILES = twophase_conf.get("default","IGNORE_OPTIONAL_FILES")

config_path = os.path.join(CONFPATH,"config_files")
CODE_SEQ=0
CODE_REFTREE=1
CODE_REFALG=2
DUMMY = "dummy"
ALIGNED = "aligned.fasta"
INPUT="input.fasta"
INITIAL_PREF = "initial."
SPFN_STAT="spfn.stat"
ALG_STAT="alg.stat"
condor_templates_path = os.path.join(CONFPATH,"condor_templates")
condor_temp_def = open(os.path.join(condor_templates_path, "condor.default")).read()

use_initial = twophase_conf.getboolean("initial", "use_initial")
use_initial_alg = twophase_conf.get("initial", "use_initial_alignment")
use_initial_alg_ml = twophase_conf.get("initial", "use_initial_alignment_ml")

if use_initial and (use_initial is None or use_initial_alg == ''): 
    raise RuntimeError("Using which initial alignment? \n \
                        set use_initial_alignment in the config file.")

def is_alignment_available (alg):
    return alg.startswith(INITIAL_PREF)

def is_data_available(code):
    return len(names)>code and names[code] != ""

def get_model_string(ml,ds_name,**kwargs):
    model = (twophase_conf.get("MODELS", "default.model") 
             if (not twophase_conf.has_option("MODELS","override.default.model.%s" %ds_name) 
                 or twophase_conf.get("MODELS","override.default.model.%s" %ds_name) == '')
             else twophase_conf.get("MODELS","override.default.model.%s" %ds_name))
    model = (model if not twophase_conf.has_option("MODELS","%s.name.model.%s"%(ml,model))
            else twophase_conf.get("MODELS","%s.name.model.%s"%(ml,model)))
    
    dt = twophase_conf.get("MODELS", "default.DT")
    dt = (dt if not twophase_conf.has_option("MODELS","%s.name.DT.%s"%(ml,dt))
            else twophase_conf.get("MODELS","%s.name.DT.%s"%(ml,dt)))                  
    g = (twophase_conf.get("MODELS", "default.G") if not kwargs.has_key("g")
         else kwargs["g"])
    g = (g if not twophase_conf.has_option("MODELS","%s.name.G.%s"%(ml,g))
            else twophase_conf.get("MODELS","%s.name.G.%s"%(ml,g)))    
    f = twophase_conf.get("MODELS", "default.F")
    f = (f if not twophase_conf.has_option("MODELS","%s.name.F.%s"%(ml,f))
            else twophase_conf.get("MODELS","%s.name.F.%s"%(ml,f)))    
    i = twophase_conf.get("MODELS", "default.I")
    i = (i if not twophase_conf.has_option("MODELS","%s.name.I.%s"%(ml,i))
            else twophase_conf.get("MODELS","%s.name.I.%s"%(ml,i)))    
    
    modelString = (twophase_conf.get("MODELS", "%s.pattern" %ml).format(DT=dt,
                                                                   G=g,
                                                                   F=f,
                                                                   I=i,
                                                                   model=model)
                   if twophase_conf.has_option("MODELS", "%s.pattern" %ml)
                   else "")
    
    #print modelString    
    return modelString
    
def copy_files_for_replica(ds_path, out_ds_path, rep, names, alg, ds_name):
    reference_seq_name = (os.path.join(ds_path, "R%d" % rep, names[CODE_SEQ]) 
                          if not use_initial and not is_alignment_available(alg) else 
                          os.path.join(twophase_conf.get("initial", "alignment"), 
                                       ds_name, "R%d" % rep, 
                                       "%s_%s" %(use_initial_alg_ml,use_initial_alg), ALIGNED))

    out_seq_path = os.path.join(out_ds_path, INPUT)    
    if IGNORE_MISSING_OPTIONAL_FILES or os.path.exists(reference_seq_name): 
        os.system('ln -sf %s %s' % (reference_seq_name, out_seq_path)) 
    else:
        raise RuntimeError("path %s does not exists." %reference_seq_name)
          
    if is_data_available(CODE_REFTREE):
        reference_tree_name = os.path.join(ds_path, "R%d" % rep, names[CODE_REFTREE])
        out_tree_path = os.path.join(out_ds_path, "reference.tre")
        if os.path.exists(reference_tree_name):
            os.system('ln -sf %s %s' % (reference_tree_name, out_tree_path)) 
        else:
            raise RuntimeError("path %s does not exists." %reference_tree_name)
    
    if is_data_available(CODE_REFALG):
        reference_alg_name = os.path.join(ds_path, "R%d" % rep, names[CODE_REFALG])
        out_alg_path = os.path.join(out_ds_path, "reference.fasta")
        if os.path.exists(reference_alg_name):
            os.system('ln -sf %s %s' % (reference_alg_name, out_alg_path))  
        else: 
            raise RuntimeError("path %s does not exists." %reference_alg_name)
    
    if is_alignment_available(alg):
        m = twophase_conf.get("initial", "alignment")
        '''copy the spfn file over'''
        if is_data_available(CODE_REFALG):
            copyfile(os.path.join(twophase_conf.get("initial", "alignment"), 
                                  ds_name, "R%d" % rep, 
                                  "%s_%s" %(use_initial_alg_ml,use_initial_alg), SPFN_STAT),
                     os.path.join(out_ds_path, SPFN_STAT))
        '''copy the alignment stat over'''
        src_path = os.path.join(twophase_conf.get("initial", "alignment"), 
                              ds_name, "R%d" % rep, 
                              "%s_%s" %(use_initial_alg_ml,use_initial_alg), ALG_STAT)
        if os.path.exists(src_path) or not IGNORE_MISSING_OPTIONAL_FILES:
            copyfile(src_path,
                 os.path.join(out_ds_path, ALG_STAT))        

    if use_initial:
        '''alignment time needs to be added with initial alignment time'''
        inital_stat_file = os.path.join(twophase_conf.get("initial", "alignment"), 
                              ds_name, "R%d" % rep, 
                              "%s_%s" %(use_initial_alg_ml,use_initial_alg), ALG_STAT)
        if os.path.exists(inital_stat_file):                    
            copyfile(inital_stat_file,
                 os.path.join(out_ds_path, "initial_%s"%ALG_STAT))
        else:
            print >>sys.stderr, "Could not find initial alignment statistics file: %s" % inital_stat_file

    
def make_ML_condor_file(outpath, ml_tool,ds_name,ml, outgroup):
    conf = twophase_conf.get("ML",ml)
    ver = "*"
    if conf.startswith("@"):
        ver = conf[1:]
        conf =""
    ml_tool_path = get_tool_path(ml_tool,ver)    
    condor_temp = (open(os.path.join(condor_templates_path, "condor.%s" % ml_tool)).read() 
                   if os.path.exists(os.path.join(condor_templates_path, "condor.%s" % ml_tool)) 
                   else condor_temp_def)
    if outgroup is not None and outgroup != "":
        outg = "-o %s" %outgroup
    else:
        outg = ""
    condor_ml = condor_temp.format(exe=ml_tool_path,
                                   input="aligned.phylip",
                                   output="ml",
                                   home=HOME,
                                   options=outpath,
                                   name="ml",
                                   model= get_model_string(ml_tool, ds_name), 
                                   outgroup=outg)
    out = open(os.path.join(outpath, "condor.ml"), "w")
    out.write(condor_ml)
    out.close()



def make_BS_condor(outpath, num, indir):
    tool_path = get_tool_path("multilocus_bootstrap")    
    condor_conv = condor_temp_def.format(exe=tool_path,
                                         options=num,
                                         input=indir,
                                         output="BS",
                                         home=HOME,
                                         name="rep")
    out = open(os.path.join(outpath, "condor.rep"), "w")
    out.write(condor_conv)
    out.close()       
    
def make_ST_condor(outpath, st_tool,ds_name,st,num):
    conf = twophase_conf.get("ST",st)
    ver = "*"
    if conf.startswith("@"):
        ver = conf[1:]
        conf =""
    tool_path = get_tool_path(st_tool,ver)    
    condor_temp = open(os.path.join(condor_templates_path, "condor.%s" % st_tool)).read()
    main = condor_temp[0:-95]
    main = main.format(name="MLBS", 
                exe=tool_path)                   
    args = condor_temp[-95:-1]
    a = []  
    for bs in range(1,num+1):
        a.append( args.format(options="BS/BS.%d"%bs,
                            input="allele.table",
                            name="BS.%d" %bs))
    condor_temp =  main + "\n".join(a)
    
    out = open(os.path.join(outpath, "condor.st"), "w")
    out.write(condor_temp)
    out.close()        
    
if __name__ == '__main__':
    
    outdir = sys.argv[1]
    BS = int(sys.argv[2]) 
    indir = sys.argv[3]
        
    
    if (os.path.exists(outdir)):
        #i = 0
        #while os.path.exists(outdir+".back.%d" %i):
        #    i += 1
        #os.rename(outdir, outdir+".back.%d"%i)
        sys.stdout.writelines("The output directory %s already exists. Do you want to proceed? (y/n)?" % outdir)        
        a = sys.stdin.readline()
        if a != "y\n":
            sys.exit(1)
    else:
        os.makedirs(outdir)
    
    require_dir(os.path.join(outdir, "logs"))
                            
    make_BS_condor(outdir, BS, indir)
    make_ST_condor(outdir, "mpest", "", "mpest", BS)