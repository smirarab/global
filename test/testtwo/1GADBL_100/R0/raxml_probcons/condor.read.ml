+Group = "GRAD"
+Project = "COMPUTATIONAL_BIOLOGY"
+ProjectDescription = "two phase method"

Universe = vanilla

Requirements = Arch == "X86_64" 
# && Memory >= 4000 && InMastodon 

executable = /projects/sate7/smirarab/workspace/global/src/mirphyl/utils/readcondorlog.py

Log = logs/rclml_condor_log

getEnv=True 

 Arguments =  logs/ml_condor_log ml.stat
 Error=logs/rclml_std.err
 Output=logs/rclml_std.out
 Queue
