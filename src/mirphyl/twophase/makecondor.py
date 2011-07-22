'''
Created on Jul 18, 2011

@author: smirarab

'''

from mirphyl.twophase import datasets, mltools, algtools, CONFPATH
from mirphyl.setup import get_datasets, get_tool_path, HOME
import sys
import os
from shutil import copyfile
from mirphyl.setup.utilities import require_dir

condor_templates_path = os.path.join(CONFPATH,"condor_templates")
condor_temp_def = open(os.path.join(condor_templates_path, "condor.default")).read()

def copy_files_for_replica(ds_path, out_ds_path, rep):
    reference_seq_name = os.path.join(ds_path, "R%d" % rep, "sequences.fasta")
    out_seq_path = os.path.join(out_ds_path, "input.fasta")
    os.system('ln -s %s %s' % (reference_seq_name, out_seq_path))
    reference_tree_name = os.path.join(ds_path, "R%d" % rep, "referencetree.pruned.tre")
    out_tree_path = os.path.join(out_ds_path, "reference.tre")
    os.system('ln -s %s %s' % (reference_tree_name, out_tree_path))
    reference_alg_name = os.path.join(ds_path, "R%d" % rep, "reference.fasta")
    out_alg_path = os.path.join(out_ds_path, "reference.fasta")
    os.system('ln -s %s %s' % (reference_alg_name, out_alg_path))


def make_alignment_condor_file(outpath, alg):
    alg_tool_path = get_tool_path(alg)    
    condor_temp = open(os.path.join(condor_templates_path, "condor.%s" % alg)).read() if os.path.exists(os.path.join(condor_templates_path, "condor.%s" % alg)) else condor_temp_def
    condor_alg = condor_temp.format(exe=alg_tool_path,
                                    input="input.fasta",
                                    output="aligned.fasta",
                                    home=HOME,
                                    options="",
                                    name="alg")
    out = open(os.path.join(outpath, "condor.align"), "w")
    out.write(condor_alg)
    out.close()
    

def make_conversion_condor_file(outpath):
    conv_tool_path = get_tool_path("readseq")    
    condor_conv = condor_temp_def.format(exe=conv_tool_path,
                                         options="-f12",
                                         input="aligned.fasta",
                                         output="-o aligned.phylip",
                                         home=HOME,
                                         name="readseq")
    out = open(os.path.join(outpath, "condor.convert"), "w")
    out.write(condor_conv)
    out.close()
    
def make_spfn_condor_file(outpath):
    conv_tool_path = get_tool_path("spfn")    
    condor_st = condor_temp_def.format(exe=conv_tool_path,
                                         input="-e aligned.fasta -r reference.fasta",
                                         output="-o spfn.stat",
                                         home=HOME,
                                         name="spfn",
                                         options="")
    out = open(os.path.join(outpath, "condor.spfn"), "w")
    out.write(condor_st)
    out.close()
    
def make_ML_condor_file(outpath, ml):
    ml_tool_path = get_tool_path(ml)    
    condor_temp = open(os.path.join(condor_templates_path, "condor.%s" % ml)).read() if os.path.exists(os.path.join(condor_templates_path, "condor.%s" % ml)) else condor_temp_def
    condor_ml = condor_temp.format(exe=ml_tool_path,
                                   input="aligned.phylip",
                                   output="ml",
                                   home=HOME,
                                   options="",
                                   name="ml")
    out = open(os.path.join(outpath, "condor.ml"), "w")
    out.write(condor_ml)
    out.close()

def make_mbrate_condor_file(outpath,ml):
    tool_path = get_tool_path("missingbranch")
    input = 'ml'
    if ml == 'raxml':
        input = 'raxml/RAxML_bestTree.ml'    
    condor_st = condor_temp_def.format(exe=tool_path,
                                         input="reference.tre %s"%input,
                                         output="mb.stat",
                                         home=HOME,
                                         name="mb",
                                         options="")
    out = open(os.path.join(outpath, "condor.mb"), "w")
    out.write(condor_st)
    out.close()

def make_time_condor_files(outpath):
    tool_path = get_tool_path("readcondorlog")    
    condor_st = condor_temp_def.format(exe=tool_path,
                                         input="logs/alg_condor_log",
                                         output="alg.stat",
                                         home=HOME,
                                         name="rcl",
                                         options="")
    out = open(os.path.join(outpath, "condor.read.alg"), "w")
    out.write(condor_st)
    out.close()
    condor_st = condor_temp_def.format(exe=tool_path,
                                         input="logs/ml_condor_log",
                                         output="ml.stat",
                                         home=HOME,
                                         name="rclml",
                                         options="")
    out = open(os.path.join(outpath, "condor.read.ml"), "w")
    out.write(condor_st)
    out.close()

if __name__ == '__main__':
    
    outdir = sys.argv[1]
        
    
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
    
    for ds in datasets:
        ds_paths, replicas = get_datasets(ds)
        for ds_path in ds_paths:
            ds_name = os.path.basename(ds_path)
            out_ds_path = os.path.join(outdir, ds_name)
            require_dir(out_ds_path)
            for rep in replicas:
                out_rep_path = os.path.join(out_ds_path, "R%d" % rep)
                require_dir(out_rep_path)
                for ml in mltools:
                    for alg in algtools:
                        out_ds_path = os.path.join(out_rep_path, "%s_%s" % (ml, alg))
                        require_dir(out_ds_path)
                        
                        require_dir(os.path.join(out_ds_path, "logs"))
                        
                        copy_files_for_replica(ds_path, out_ds_path, rep)
                        
                        make_alignment_condor_file(out_ds_path, alg)                                                                 
                        make_spfn_condor_file(out_ds_path)                    
                        make_conversion_condor_file(out_ds_path)                                                                                             
                        make_ML_condor_file(out_ds_path, ml)                        
                        make_mbrate_condor_file(out_ds_path,ml)
                        make_time_condor_files(out_ds_path)
                        
                        copyfile(os.path.join(condor_templates_path,'condor.dag'),
                                 os.path.join(out_ds_path,'dagfile'))