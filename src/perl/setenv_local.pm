#!/usr/bin/env perl

# testing

# most useful for fixing directories to make scripts more easily portable

# nice this works
package setenv_local;

use strict;

# mutable depending on installation directory - so all simstudy code
# knows how to access all components used
use constant RESEARCH_DIR_LOCAL => "/projects/sate4/smirarab/kevinrep/";
# kliu - remove java local dependency - just ship it along with code
# repository
# crap - 32-bit vs. 64-bit java important for performance 
# update this during install

# need this flag to more intelligently choose scripts/programs
# automatically
# for now, just 32 or 64 bit - can change this later as need be
use constant ARCHITECTURE_64_BIT_FLAG => 0;

# java availability
use constant JAVA_HOME_32_BIT => RESEARCH_DIR_LOCAL . "/jdk1.6.0_02_32_bit";
use constant JAVA_HOME_64_BIT => "/usr";
use constant JAVA_HOME => JAVA_HOME_64_BIT;

# perl availability
# need this too - due to older perl interpreter only on TACC
use constant PERL_HOME_32_BIT => "/lusr/bin";
# crap - couldn't get perl 5.8.8 to build of TACC
# just use old perl 5.8.5 and import Time::HiRes manually
# huh - perl 5.8.5 works?? on TACC - gettimeofday seems to work?
# has Time::HiRes already?? check ~/test_perl
use constant PERL_HOME_64_BIT => "/usr/bin";
use constant PERL_HOME => PERL_HOME_32_BIT;

# perl - different for TACC
use constant PERL_COMMAND => PERL_HOME . "/perl";

use constant CONDOR_BINARIES_DIR => "/lusr/condor/bin";

# change this depending on application
use constant CONDOR_SUBMIT_DAG_MAXJOBS => 100;

# hmm - no, problem on TACC is mostly that compute nodes don't
# like the installed Time/HiRes.pm module located at /usr/lib64/perl5/5.8.5/x86_64-linux-thread-multi
# instead, manually build the required library and put it in <codedir>/global
# so it'll get used instead

# enforce BASH interpret all shell scripts
use constant BASH_COMMAND => "/bin/bash";

# for python support
use constant PYTHON_COMMAND => "/lusr/bin/python";

1;
