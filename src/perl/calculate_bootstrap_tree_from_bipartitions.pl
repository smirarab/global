#!/usr/bin/env perl

# calculate bootstrap tree from bipartitions output

# pick up global settings
#use FindBin qw($WS_HOME);
use lib "$ENV{WS_HOME}/global/src/perl";
use setenv;
use framework;
# also make environment changes
setenv::setenv();

use Getopt::Std;
use Cwd;

# for sanity's sake
use strict;

# for hi res timing - from Li-San
use Time::HiRes qw(gettimeofday);

# for temp files
use File::Temp qw/ tempfile tempdir /;

sub process {
    my $infile = shift;
    my $outfile = shift;
    my $threshold = shift;

    my $scriptdir = getcwd;

    if (!(-e $infile) || (-z $infile)) {
	die "ERROR: $infile doesn't exist! Exiting.\n";
    }

    chdir (setenv::SINDHU_CODE_DIR);
    framework::systemSafe(setenv::JAVA_COMMAND . " com.dcm.newick.BootstrapTree -i $infile -o $outfile -t $threshold");
    chdir ($scriptdir);

    # postprocess
    my $treestring = framework::getStringFromFile($outfile);

    $treestring =~ s/\)[0-9]+/\)/g;
    $treestring =~ s/\)null/\)/g;

    open (OUT, ">$outfile");
    print OUT "$treestring\n";
    close (OUT);
}

sub printUsage {
    print STDERR
	"Usage: perl calculate_bootstrap_tree_from_bipartitions.pl \n" .
	"       -i <input RAxML bipartitions file with FULL PATH> REQUIRED \n" .
	"       -o <output bootstrap tree with FULL PATH> REQUIRED \n" .
	"       -t <bootstrap threshold in [0-100]> \n"
;
    exit 1;
}

# output all stats to STATS file directly
sub main {
    # for now, just pass in 
    # raw sequences file (with path)
    getopt("iot");

    if (($Getopt::Std::opt_i eq "") ||
	($Getopt::Std::opt_o eq "") ||
	($Getopt::Std::opt_t eq "") 
	) {	
	printUsage;
    }

    my $currdir = getcwd;

    $Getopt::Std::opt_i =~ s/CURRDIR\_MARKER/$currdir/g;
    $Getopt::Std::opt_o =~ s/CURRDIR\_MARKER/$currdir/g;

    print "Processing $Getopt::Std::opt_i...";

    # use $workdir instead of $Getopt::Std::opt_w
    process($Getopt::Std::opt_i,
	    $Getopt::Std::opt_o,
	    $Getopt::Std::opt_t
	    );

    print "done.\n";
}

main;

