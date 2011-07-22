+Group = "GRAD"
+Project = "COMPUTATIONAL_BIOLOGY"
+ProjectDescription = "two phase method"

Universe = vanilla

Requirements = Arch == "X86_64" 
# && Memory >= 4000 && InMastodon 

executable = /projects/sate7/smirarab/workspace/global/src/mirphyl/utils/readcondorlog.py

Log = logs/rcl_condor_log

getEnv=True 

 Arguments =  logs/alg_condor_log alg.stat
 Error=logs/rcl_std.err
 Output=logs/rcl_std.out
 Queue
