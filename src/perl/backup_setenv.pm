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

# directories for clustalw
use constant CLUSTALW_DIR => RESEARCH_DIR . "/clustal";
use constant CLUSTALW_EXECUTABLE => CLUSTALW_DIR . "/clustalw";
use constant CLUSTALW_CONDOR_DIR => RESEARCH_DIR . "/clustal_condor";
use constant CLUSTALW_CONDOR_EXECUTABLE => CLUSTALW_CONDOR_DIR . "/clustalw";


# directories for mafft
use constant MAFFT_DIR => RESEARCH_DIR . "/mafft_bin";
use constant MAFFT_EXECUTABLE => MAFFT_DIR . "/mafft";
use constant MAFFT_LIB => RESEARCH_DIR . "/mafft_lib";
# for recompilation
use constant MAFFT_BUILD_DIR => RESEARCH_DIR . "/mafft_install/mafft-6.240";

# directories for muscle
use constant MUSCLE_DIR => RESEARCH_DIR . "/muscle";
use constant MUSCLE_EXECUTABLE => MUSCLE_DIR . "/muscle";
use constant MUSCLE_CONDOR_DIR => RESEARCH_DIR . "/muscle_condor";
use constant MUSCLE_CONDOR_EXECUTABLE => MUSCLE_CONDOR_DIR . "/muscle";

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
use constant JAVA_COMMAND => JAVA_HOME . "/bin/java -cp " . CLASSPATH . " -Xms1024m -Xmx1024m ";
# for installer
use constant JAVAC_COMMAND => JAVA_HOME . "/bin/javac -cp " . CLASSPATH . " ";

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

# random refine dir
use constant RANDOM_REFINE_DIR => RESEARCH_DIR . "/dcm3/random_refine";
use constant RANDOM_REFINE_EXECUTABLE => RANDOM_REFINE_DIR . "/random_refine";

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
use constant POY_4_DIR => RESEARCH_DIR . "/poy4_2398";
use constant POY_4_EXECUTABLE => POY_4_DIR . "/seq_poy.command";

# raxml dir
use constant RAXML_DIR => RESEARCH_DIR . "/raxml/RAxML-7.0.4";
use constant RAXML_EXECUTABLE => RAXML_DIR . "/raxmlHPC";

# raxml condor dir
use constant RAXML_CONDOR_DIR => RESEARCH_DIR . "/raxml_condor";
use constant RAXML_CONDOR_EXECUTABLE => RAXML_CONDOR_DIR . "/raxmlHPC";

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


# probcons dir
use constant PROBCONS_DIR => RESEARCH_DIR . "/probconsrna";
use constant PROBCONS_EXECUTABLE => PROBCONS_DIR . "/probcons";

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

use constant PRANK_DIR => RESEARCH_DIR . "/prank/prank.080904";
use constant PRANK_EXECUTABLE => PRANK_DIR . "/prank";

use constant PRANK_CONDOR_DIR => RESEARCH_DIR . "/prank/prank.080904_condor";
use constant PRANK_CONDOR_EXECUTABLE => PRANK_CONDOR_DIR . "/prank";

# if using this, remember to manually set MAFFT_BINARIES environment 
# variable in your script prior to using it! because setenv::setenv()
# sets it differently!
use constant MAFFT_GUIDE_TREE_DIR => RESEARCH_DIR . "/mafft-6.504-treein";

use constant ALIFRITZ_DIR => RESEARCH_DIR . "/alifritz/alifritz_linux_1.0";
use constant ALIFRITZ_EXECUTABLE => ALIFRITZ_DIR . "/alifritz";
use constant ALIFRITZ_CONDOR_DIR => RESEARCH_DIR . "/alifritz/alifritz_src_1.0_condor";
use constant ALIFRITZ_CONDOR_EXECUTABLE => ALIFRITZ_CONDOR_DIR . "/alifritz";


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
    $ENV{"MAFFT_BINARIES"} = MAFFT_LIB;
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

    
}

1;
