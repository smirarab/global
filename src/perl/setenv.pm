#!/usr/bin/env perl

package setenv;

use strict;
use setenv_local;

# simstudy file format is:
# <model condition, with all params separated by _>/<R? run number>/<any method, alignest or treeest or align+treeest, with all params separated by _>
# model condition run dir has STATS file and so does method dir
# true alignment file stored at rundir

# pick up local settings
use constant RESEARCH_DIR => setenv_local::RESEARCH_DIR_LOCAL;

use constant BASH_COMMAND => setenv_local::BASH_COMMAND;
use constant PYTHON_COMMAND => setenv_local::PYTHON_COMMAND;


# java availability - pickup from setenv_local due to 
# 32-bit vs. 64-bit interpreter issue
use constant JAVA_HOME => setenv_local::JAVA_HOME;

# perl availability
use constant PERL_HOME => setenv_local::PERL_HOME;

# only a few fixed files in structure
use constant STATS_FILENAME => "STATS";

# global non-mutable regardless of installation dirs due to relative
# pathnames
#use constant RECDCM3_DIR => RESEARCH_DIR . "/dcm3/recdcm3";
#use constant RECDCM3_EXECUTABLE => RECDCM3_DIR . "/recdcm3";
# use correct recidcm3 implementation - symlink in lisan_dcm
# this isn't used anymore
#use constant DNADATADIR => LOCALFILESDIR . "/dnadata";
#use constant AADATADIR => LOCALFILESDIR. "/aadata";

# for recompilation
use constant DCM3_DIR => RESEARCH_DIR . "/dcm3";

##directories for prank
# this one isn't used!!!
#use constant PRANK_DIR => RESEARCH_DIR . "/prank";

use constant PRANK_DIR => RESEARCH_DIR . "/prank/prank.081202";
use constant PRANK_EXECUTABLE => PRANK_DIR . "/prank";

use constant PRANK_64_DIR => RESEARCH_DIR . "/prank/prank.081202_64";
use constant PRANK_64_EXECUTABLE => PRANK_64_DIR . "/prank";

use constant PRANK_CONDOR_DIR => RESEARCH_DIR . "/prank/prank.081202_condor";
use constant PRANK_CONDOR_EXECUTABLE => PRANK_CONDOR_DIR . "/prank";

use constant PRANK_091016_DIR => RESEARCH_DIR . "/prank/prank.091016";
use constant PRANK_091016_EXECUTABLE => PRANK_091016_DIR . "/prank";

use constant PRANK_091016_CONDOR_DIR => RESEARCH_DIR . "/prank/prank.091016_condor";
use constant PRANK_091016_CONDOR_EXECUTABLE => PRANK_091016_CONDOR_DIR . "/prank";


# directories for clustalw
use constant CLUSTALW_DIR => RESEARCH_DIR . "/clustal/clustalw-2.0.12";
use constant CLUSTALW_EXECUTABLE => CLUSTALW_DIR . "/clustalw";
use constant CLUSTALW_CONDOR_DIR => RESEARCH_DIR . "/clustal/clustalw-2.0.12_condor";
use constant CLUSTALW_CONDOR_EXECUTABLE => CLUSTALW_CONDOR_DIR . "/clustalw";


# directories for mafft
use constant MAFFT_DIR => RESEARCH_DIR . "/mafft_bin";
use constant MAFFT_EXECUTABLE => MAFFT_DIR . "/mafft";
use constant MAFFT_LIB => RESEARCH_DIR . "/mafft_lib";
use constant MAFFT_64_DIR => RESEARCH_DIR . "/mafft_64";
use constant MAFFT_64_EXECUTABLE => MAFFT_64_DIR . "/bin/mafft";
use constant MAFFT_64_LIB => RESEARCH_DIR . "/mafft_64/lib";
# for recompilation
use constant MAFFT_INSTALL_DIR => RESEARCH_DIR . "/mafft_install";
use constant MAFFT_BUILD_DIR => RESEARCH_DIR . "/mafft_install/mafft-6.240";
# for latest MAFFT - need to wrap it to reset MAFFT_BINARIES appropriately
use constant MAFFT_NEW_DIR => RESEARCH_DIR . "/mafft_install/mafft-6.864-with-extensions";
use constant MAFFT_NEW_64_DIR => RESEARCH_DIR . "/mafft_install/mafft-6.864-with-extensions";


# directories for muscle
use constant MUSCLE_DIR => RESEARCH_DIR . "/muscle";
use constant MUSCLE_EXECUTABLE => MUSCLE_DIR . "/muscle";
use constant MUSCLE_64_DIR => RESEARCH_DIR . "/muscle_64";
use constant MUSCLE_64_EXECUTABLE => MUSCLE_64_DIR . "/muscle";
use constant MUSCLE_CONDOR_DIR => RESEARCH_DIR . "/muscle_condor";
use constant MUSCLE_CONDOR_EXECUTABLE => MUSCLE_CONDOR_DIR . "/muscle";

#directories for opal
use constant OPAL_DIR => RESEARCH_DIR . "/opal";
# kliu - remember to update this symlink since this jar symlink
# is to Opal 1.0.2 version!!!
use constant OPAL_JARFILE => OPAL_DIR . "/Opal.jar";

#directories for satchmo
use constant SATCHMO_DIR => RESEARCH_DIR . "/satchmo/satchmo/src";


# directories for poa
use constant POA_DIR => RESEARCH_DIR . "/poa";

# directories for DCA
use constant DCA_DIR => RESEARCH_DIR . "/dca";
# WARNING - DCA requires MSA to work!!!
use constant DCA_MSA_DIR => RESEARCH_DIR . "/dca/msa";
use constant DCA_EXECUTABLE => RESEARCH_DIR . "/dca/dca";
use constant DCA_MSA_EXECUTABLE => RESEARCH_DIR . "/dca/msa/msa";

# directories for recdcm3
use constant DCM_DIR => RESEARCH_DIR . "/lisan_dcm";
use constant DCM_64_DIR => RESEARCH_DIR . "/lisan_dcm_64";

# for now not used?
# state types
use constant AADATATYPE => "AA";
use constant DNADATATYPE => "DNA";

# bioperl dirs
use constant BIOPERL_DIR => RESEARCH_DIR . "/bioperl-1.5.0";

# jakarta commons cli jar
use constant JAKARTA_COMMONS_CLI_JAR => RESEARCH_DIR . "/cli/commons-cli-1.0/commons-cli-1.0.jar";

# Java
use constant CLASSPATH => ".:" . RESEARCH_DIR . "/jama/Jama-1.0.2.jar:" . RESEARCH_DIR . "/pal_bin/pal-1.5.1.jar:" . JAKARTA_COMMONS_CLI_JAR . ":" . $ENV{"CLASSPATH"};
# kliu - set the initial size smaller - can cause issues when one java
# process invokes another java process
use constant JAVA_COMMAND => JAVA_HOME . "/bin/java -cp " . CLASSPATH . " -Xms64m -Xmx1024m ";
# for installer
use constant JAVAC_COMMAND => JAVA_HOME . "/bin/javac -cp " . CLASSPATH . " ";
use constant JAVA_EQUALMEM_COMMAND => JAVA_HOME . "/bin/java -cp " . CLASSPATH . " -Xms1024m -Xmx1024m ";
# for medium memory runs - warning - you need to guarantee compute
# node with at least 4GB main memory to use this! otherwise
# java vm instantiation fails!
use constant JAVA_MOREMEM_COMMAND => JAVA_HOME . "/bin/java -cp " . CLASSPATH . " -Xms1024m -Xmx1900m ";
# for large memory runs
use constant JAVA_MEM_COMMAND => JAVA_HOME . "/bin/java -cp " . CLASSPATH . " -Xms1024m -Xmx2500m ";

# 64-bit java
use constant JAVA_64_COMMAND => setenv_local::JAVA_HOME_64_BIT . "/bin/java -cp " . setenv::CLASSPATH . " -Xms2048m -Xmx6000m ";


# perl
use constant PERL_COMMAND => setenv_local::PERL_COMMAND;

# ruby
use constant RUBY_DIR => RESEARCH_DIR . "/ruby/ruby-1.8.7-p72";
use constant RUBY_COMMAND => RUBY_DIR . "/ruby";

# custom java dirs
use constant CUSTOM_DIR => RESEARCH_DIR . "/distance";

# distance-based tree estimation dirs
use constant FASTME_DIR => RESEARCH_DIR . "/fastme/bin";
use constant FASTME_EXECUTABLE => FASTME_DIR . "/fastme";
use constant FASTME_BUILD_DIR => RESEARCH_DIR . "/fastme";

# weighbor dirs
use constant WEIGHBOR_DIR => RESEARCH_DIR . "/weighbor";

# NINJA dirs
use constant NINJA_DIR => RESEARCH_DIR . "/ninja/ninja_1.2.1";

# random refine dir
use constant RANDOM_REFINE_DIR => RESEARCH_DIR . "/dcm3/random_refine";
use constant RANDOM_REFINE_EXECUTABLE => RANDOM_REFINE_DIR . "/random_refine";
use constant RANDOM_REFINE_64_DIR => RESEARCH_DIR . "/dcm3_64/random_refine";
use constant RANDOM_REFINE_64_EXECUTABLE => RANDOM_REFINE_64_DIR . "/random_refine";

# random refine condor dir
use constant RANDOM_REFINE_CONDOR_DIR => RESEARCH_DIR . "/dcm3/random_refine_condor";
use constant RANDOM_REFINE_CONDOR_EXECUTABLE => RANDOM_REFINE_CONDOR_DIR . "/random_refine";


# phylip dirs
use constant PHYLIP_DIR => RESEARCH_DIR . "/phyexe";
# for recompilation
use constant PHYLIP_BUILD_DIR => RESEARCH_DIR . "/phylip3.65";

# gsp script dir
use constant GSP_DIR => RESEARCH_DIR . "/sate";

# need a modded sate dir
use constant GSP_MODDING_DIR => RESEARCH_DIR . "/sate_modding";

# POY 3.0 directory
use constant POY_DIR => RESEARCH_DIR . "/poy_modified_by_usman";

# POY 4.0 beta directory
use constant POY_4_DIR => RESEARCH_DIR . "/poy4/poy-4.1.2/bin";
use constant POY_4_EXECUTABLE => POY_4_DIR . "/poy";

use constant PARSIMONATOR_DIR => RESEARCH_DIR . "/raxml/Parsimonator-1.0.2_sse3";
use constant PARSIMONATOR_EXECUTABLE => PARSIMONATOR_DIR . "/parsimonator-SSE3";

use constant PARSIMONATOR_64_DIR => RESEARCH_DIR . "/raxml/Parsimonator-1.0.2_sse3_64";
use constant PARSIMONATOR_64_EXECUTABLE => PARSIMONATOR_64_DIR . "/parsimonator-SSE3";



# raxml dir
# not all CPUs in UTCS department support SSE3 instructions
# e.g. balrog-*
# use non-SSE3-compiled version
use constant RAXML_DIR => RESEARCH_DIR . "/raxml/RAxML-7.2.6";
use constant RAXML_EXECUTABLE => RAXML_DIR . "/raxmlHPC";

use constant RAXML_64_DIR => RESEARCH_DIR . "/raxml/RAxML-7.2.6_sse3_64bit";
use constant RAXML_64_EXECUTABLE => RAXML_64_DIR . "/raxmlHPC-SSE3";

use constant RAXML_64_DMTCP_DIR => RESEARCH_DIR . "/raxml/RAxML-7.2.6_sse3_64bit_dmtcp";
use constant RAXML_64_DMTCP_EXECUTABLE => RAXML_64_DMTCP_DIR . "/raxmlHPC-SSE3";
use constant RAXML_PTHREADS_64_DMTCP_DIR => RESEARCH_DIR . "/raxml/RAxML-7.2.6_sse3_PTHREADS_64bit_dmtcp";
use constant RAXML_PTHREADS_64_DMTCP_EXECUTABLE => RAXML_PTHREADS_64_DMTCP_DIR . "/raxmlHPC-PTHREADS-SSE3";

# super-fast, low-memory alpha version of RAxML 64-bit sse3
use constant RAXML_ALPHA_64_DIR => RESEARCH_DIR . "/raxml/RAxML-7.2.6_sse3_64bit";
use constant RAXML_ALPHA_64_EXECUTABLE => RAXML_ALPHA_64_DIR . "/raxmlHPC-SSE3";

use constant RAXML_PTHREADS_64_DIR => RESEARCH_DIR . "/raxml/RAxML-7.2.6_sse3_PTHREADS_64bit";
use constant RAXML_PTHREADS_64_EXECUTABLE => RAXML_PTHREADS_64_DIR . "/raxmlHPC-PTHREADS-SSE3";

# raxml condor dir
use constant RAXML_CONDOR_DIR => RESEARCH_DIR . "/raxml/RAxML-7.2.6_condor";
use constant RAXML_CONDOR_EXECUTABLE => RAXML_CONDOR_DIR . "/raxmlHPC";

# for obsolete RAxML backwards compatability
use constant RAXML_OLD_DIR => RESEARCH_DIR . "/raxml/RAxML-7.0.4";

# exact median estimator dir
use constant MED_DIR => RESEARCH_DIR . "/exact_median";

# needleman-wunsch global pairwise alignment matrix code
use constant PAIRALIGN_DIR => RESEARCH_DIR . "/pairalign";
use constant PAIRALIGN_COMMAND => PAIRALIGN_DIR . "/nwaffine";

use constant PAIRALIGN_CONDOR_DIR => RESEARCH_DIR . "/pairalign_condor";
use constant PAIRALIGN_CONDOR_COMMAND => PAIRALIGN_CONDOR_DIR . "/nwaffine";

# paup dir
use constant PAUP_DIR => RESEARCH_DIR . "/paup";
use constant PAUP_EXECUTABLE => PAUP_DIR . "/bin/paup";

use constant PAUP_CONDOR_DIR => RESEARCH_DIR . "/paup_condor/condor_paup";
use constant PAUP_CONDOR_EXECUTABLE => PAUP_CONDOR_DIR . "/paup4b10-x86-linux-condor";

# tnt dir
use constant TNT_DIR => RESEARCH_DIR . "/tnt/tnt_32";
use constant TNT_EXECUTABLE => TNT_DIR . "/tnt";
use constant TNT_64_DIR => RESEARCH_DIR . "/tnt/tnt_64";
use constant TNT_64_EXECUTABLE => TNT_64_DIR . "/tnt";


# Siavash's FastMRP code
use constant FASTMRP_DIR => RESEARCH_DIR . "/fastmrp";
use constant FASTMRP_JAR => FASTMRP_DIR . "/mrp.jar";

# probcons dir
use constant PROBCONS_DIR => RESEARCH_DIR . "/probconsrna";
use constant PROBCONS_EXECUTABLE => PROBCONS_DIR . "/probcons";

use constant PROBCONSAA_DIR => RESEARCH_DIR . "/probconsAA_1.12";
use constant PROBCONSAA_EXECUTABLE => PROBCONSAA_DIR . "/probcons";

# probcons condor dir
use constant PROBCONS_CONDOR_DIR => RESEARCH_DIR . "/probconsrna_condor";
use constant PROBCONS_CONDOR_EXECUTABLE => PROBCONS_CONDOR_DIR . "/probcons";

# also need simcode directories
use constant CALLROSE_DIR => RESEARCH_DIR . "/callrose";
use constant R8S_DIR => RESEARCH_DIR . "/lisan_r8s";
use constant LISAN_LIB_DIR => RESEARCH_DIR . "/lisan_lib";
use constant R8S_BIN_DIR => RESEARCH_DIR . "/r8s";
use constant ROSE_INSTALL_DIR => RESEARCH_DIR . "/rose_install";
use constant ROSE_DIR => RESEARCH_DIR . "/rose";

# method code scripts needed
use constant METHODCODE_DIR => RESEARCH_DIR . "/methodcode";
use constant METHODCODE_ONEOFF_DIR => RESEARCH_DIR . "/methodcode_oneoff";

# for mouse experiments
use constant MOUSE_SCRIPTS_DIR => RESEARCH_DIR . "/mouse-scripts";

# AMAC - custom ama calculator
use constant AMAC_DIR => RESEARCH_DIR . "/amac";
# YAAM - custom YAAM calculator
use constant YAAM_DIR => RESEARCH_DIR . "/yaam";

use constant GMP_LIB_DIR => RESEARCH_DIR . "/gmp/lib";

# also need gnuplot directories
use constant GNUPLOT_DIR => RESEARCH_DIR . "/gnuplot";
use constant GNUPLOT_BIN => GNUPLOT_DIR . "/bin/gnuplot";

# also need condor_script directories
use constant CONDOR_SCRIPT_DIR => RESEARCH_DIR . "/condor_scripts";

use constant CONDOR_SUBMIT_DAG_MAXJOBS => setenv_local::CONDOR_SUBMIT_DAG_MAXJOBS;
use constant CONDOR_BINARIES_DIR => setenv_local::CONDOR_BINARIES_DIR ;
use constant CONDOR_SUBMIT_COMMAND => setenv::CONDOR_BINARIES_DIR . "/condor_submit";
use constant CONDOR_SUBMIT_DAG_COMMAND => setenv::CONDOR_BINARIES_DIR . "/condor_submit_dag -maxjobs " . CONDOR_SUBMIT_DAG_MAXJOBS . " -notification error -allowlogerror";

use constant TIME_DIR => RESEARCH_DIR . "/time";

use constant RATCHET_DIR => RESEARCH_DIR . "/ratchet";

use constant AMAP_RNA_DIR => RESEARCH_DIR . "/amap_rna/align";
use constant AMAP_RNA_CONDOR_DIR => RESEARCH_DIR . "/amap_rna_condor/align";

use constant MPA_DIR => RESEARCH_DIR . "/mpa";
use constant MPA_EXECUTABLE => MPA_DIR . "/compAncestralSeq";

# unable to condor compile - problem with gcc 3.3
use constant GARLI_DIR => RESEARCH_DIR . "/garli/GARLIv0.951/src";
use constant GARLI_EXECUTABLE => GARLI_DIR . "/Garli0.951";

use constant ML_GAPS_DIR => RESEARCH_DIR . "/ml_gaps";
use constant ML_GAPS_EXECUTABLE => ML_GAPS_DIR . "/likelihoodCalculator";

use constant TREE_PRUNER_DIR => RESEARCH_DIR . "/treePruner";

use constant SINDHU_CODE_DIR => RESEARCH_DIR . "/sindhu_dcm_code/src";
use constant SERITA_CODE_DIR => RESEARCH_DIR . "/serita_scripts";

# if using this, remember to manually set MAFFT_BINARIES environment 
# variable in your script prior to using it! because setenv::setenv()
# sets it differently!
use constant MAFFT_GUIDE_TREE_DIR => RESEARCH_DIR . "/mafft-6.504-treein";
use constant MAFFT_GUIDE_TREE_64_DIR => RESEARCH_DIR . "/mafft-6.504-treein_64";

use constant ALIFRITZ_DIR => RESEARCH_DIR . "/alifritz/alifritz_linux_1.0";
use constant ALIFRITZ_EXECUTABLE => ALIFRITZ_DIR . "/alifritz";
use constant ALIFRITZ_CONDOR_DIR => RESEARCH_DIR . "/alifritz/alifritz_src_1.0_condor";
use constant ALIFRITZ_CONDOR_EXECUTABLE => ALIFRITZ_CONDOR_DIR . "/alifritz";

use constant BALIPHY_DIR => RESEARCH_DIR . "/baliphy/bali-phy-2.1.1_64/bin";
use constant BALIPHY_EXECUTABLE => BALIPHY_DIR . "/bali-phy";

# 64bit version
use constant BALIPHY_64_DIR => RESEARCH_DIR . "/baliphy/bali-phy-2.1.1_64/bin";
use constant BALIPHY_64_EXECUTABLE => BALIPHY_64_DIR . "/bali-phy";

# gblocks
use constant GBLOCKS_DIR => RESEARCH_DIR . "/gblocks/Gblocks_0.91b";
use constant GBLOCKS_EXECUTABLE => GBLOCKS_DIR . "/Gblocks";

# SuperFine
# python runReup.py
use constant SUPERFINE_DIR => RESEARCH_DIR . "/reup";
use constant SUPERFINE_EXECUTABLE => SUPERFINE_DIR . "/reup.pl";
# for PAUP* dependency
use constant SUPERFINE_SCRIPTS_DIR => RESEARCH_DIR . "/reup/reup-1.0/reup/scripts";
use constant SUPERFINE_SCRIPTS_EXECUTABLE => PYTHON_COMMAND . " " . SUPERFINE_SCRIPTS_DIR . "/runReup.py";

# DACTAL
use constant DACT_DIR => RESEARCH_DIR . "/dact";

# FastTree
use constant FASTTREE_DIR => RESEARCH_DIR . "/fasttree/fasttree-2.1.3";
use constant FASTTREE_EXECUTABLE => FASTTREE_DIR . "/FastTree";

use constant FASTTREE_64_DIR => RESEARCH_DIR . "/fasttree/fasttree-2.1.3_64";
use constant FASTTREE_64_EXECUTABLE => FASTTREE_64_DIR . "/FastTree";
use constant FASTTREEMP_64_EXECUTABLE => FASTTREE_64_DIR . "/FastTreeMP";

# FSA
use constant FSA_64_DIR => RESEARCH_DIR . "/fsa/fsa-1.15.5_64/bin";
use constant FSA_64_EXECUTABLE => FSA_64_DIR . "/fsa";
use constant FSA_64_CONDOR_DIR => RESEARCH_DIR . "/fsa/fsa-1.15.5_64_condor/bin";
use constant FSA_64_CONDOR_EXECUTABLE => FSA_64_CONDOR_DIR . "/fsa";

use constant COMPARETREE_DIR => RESEARCH_DIR . "/compareTree";
use constant COMPARETREE_EXECUTABLE => COMPARETREE_DIR . "/missingBranchRate.pl";

# DMTCP v 1.2 seems to be working well for checkpointing
use constant DMTCP_DIR => RESEARCH_DIR . "/dmtcp/dmtcp_1.2.0_32/bin";
use constant DMTCP_EXECUTABLE => DMTCP_DIR . "/dmtcp_checkpoint";
use constant DMTCP_64_DIR => RESEARCH_DIR . "/dmtcp/dmtcp_1.2.0_64/bin";
use constant DMTCP_64_EXECUTABLE => DMTCP_64_DIR . "/dmtcp_checkpoint";

# BEAGLE
use constant BEAGLE_DIR => RESEARCH_DIR . "/beagle";

# MS for coalescent model simulations
use constant MS_64_CONDOR_DIR => RESEARCH_DIR . "/ms/ms_64bit_condor";
use constant MS_64_CONDOR_EXECUTABLE => MS_64_CONDOR_DIR . "/ms";



# need to tweak this

# this should never be used - master script handles this as a command line
# parameter, or else (preferably) use qsub or condor
#use constant NUMBER_PROCESSORS => 1;


# make environment changes
# CALL THIS TO MAKE CHANGES TO PATH AND OTHER STUFF IN PERLSCRIPT!!!

sub setenv {
    $ENV{PATH} .= ":" . DCA_MSA_DIR;
    $ENV{PATH} .= ":" . MAFFT_LIB;

    # also need to do MAFFT_BINARIES
    # kliu - eh, should always do this
    # just in case user environment has some crazy setting here
    #if (!defined($ENV{"MAFFT_BINARIES"})) {

    if (defined(setenv_local::ARCHITECTURE_64_BIT_FLAG) && (setenv_local::ARCHITECTURE_64_BIT_FLAG eq "1")) {
	$ENV{"MAFFT_BINARIES"} = MAFFT_64_LIB;
    }
    else {
	$ENV{"MAFFT_BINARIES"} = MAFFT_LIB;
    }
    
    #}

    # paranoia - also reset CLASSPATH here
    if (!defined($ENV{"CLASSPATH"})) {
	$ENV{"CLASSPATH"} = CLASSPATH;
    }
    else {
	$ENV{"CLASSPATH"} .= ":" . CLASSPATH;
    }

    if (!defined($ENV{"LD_LIBRARY_PATH"})) {
	$ENV{"LD_LIBRARY_PATH"} = GMP_LIB_DIR;
    }
    else {
	$ENV{"LD_LIBRARY_PATH"} .= ":" . GMP_LIB_DIR;
    }

    push(@INC, setenv::COMPARETREE_DIR);

}

1;
