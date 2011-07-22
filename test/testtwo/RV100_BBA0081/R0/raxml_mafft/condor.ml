+Group = "GRAD"
+Project = "COMPUTATIONAL_BIOLOGY"
+ProjectDescription = "two phase method"

Universe = vanilla

Requirements = Arch == "X86_64"
# && Memory >= 4000 && InMastodon 

executable = /projects/sate7/tools/bin/raxmlHPC-7.2.6-64bit

Log = logs/ml_condor_log
 

 Arguments = -m PROTCATWAGF -n ml -s aligned.phylip -w raxml
 Error=logs/ml_std.err
 Output=logs/ml_std.out
 Queue
