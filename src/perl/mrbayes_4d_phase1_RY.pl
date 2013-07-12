#!/usr/bin/perl

=head1 Name

mrbayes_species_4d_phase1.pl

=head1 Description

mb-shell for species tree of 4d and pahse 1

=head1 Version

 Author: Bo li, libo@genomics.org.cn
 Version: 1.0,  Date: 2009-8-12
 notion:
  The input file should be in philip-fomart.
  The *4d.interleave.nex is input for infer 4d-mrbayes-species tree.
  The *phase1.interleave.nex is input for infer phase_1-mrbayes-species tree.
  Shell (all.philip.4d.sh or all.philip.phase1.sh) for qsub,should use "-l vf=15G".

=head1 Usage

 perl mrbayes_species_4d_phase1.pl  [options] <philip> 
 --direction DIR for output, default ./

=head1 Exmple
 
 perl bin/mrbayes_species_4d_phase1.pl --direction Mb output/all.philip

=cut



use strict;
use Getopt::Long;
use FindBin qw($Bin);
use lib "$Bin../lib";

my $mb_pathway = "$Bin/../lib";

my $direction;
GetOptions(
        "direction:s"=>\$direction
);

$direction ||= ".";
$direction =~ s/\/$//;
die `pod2text $0` if (@ARGV != 1 );

my $philip_file=shift;
my @slashes =split /\//,$philip_file;
my $file_name =$slashes[-1];

###################################################################################
##step 1 4dsite

my $file_4d =&extract_4dsite_from_philip($philip_file,"$direction/$file_name"); #sub 1 extract_4dsite

my $file_interleave =&interleave_readseq($file_4d); #sub 2 produce interleave format

my $file_4d = &nex_produce($file_interleave); #sub 3 produce nex



###################################################################################
##step 2 phase 1 in condon

my $file_phase_1=&phase_1_extract($philip_file,"$direction/$file_name"); #sub 4 

my $file_interleave=&interleave_readseq($file_phase_1); #sub 2

my $file_phase1 =&nex_produce($file_interleave); #sub 3 produce nex


###################################################################################
##

my $file_RY = &RY_coding_file($philip_file,"$direction/$file_name"); #sub 5

my $file_interleave = &interleave_readseq($file_RY); #sub 2

my $file_RY = &nex_produce($file_interleave); #sub 3 produce nex

###################################################################################
##step 4 .sh for qsub

open IN,">$direction/$file_name.4d.sh" or die;
print IN "mpirun -np 4 $mb_pathway/mb -i  $file_4d";
close IN;

open IN,">$direction/$file_name.phase1.sh" or die;
print IN "mpirun -np 4 $mb_pathway/mb -i $file_phase1";
close IN;

open IN,">$direction//$file_name.RY.sh" or die;
print IN "mpirun -np 4 $mb_pathway/mb -i $file_RY";
close IN;

###################################################################################
## step 5 for whole sequence

`cp $philip_file $direction/$file_name` unless (-e  "$direction/$file_name");
my $file_interleave=&interleave_readseq("$direction/$file_name"); #sub 2
my $file_wh = &nex_produce($file_interleave); #sub 3 produce nex

open IN,">$direction/$file_name.sh" or die;
print IN "mpirun -np 4 $mb_pathway/mb -i $file_wh";
close IN;



############################################
##                subs                ######
############################################

## sub 1 
##
sub extract_4dsite_from_philip{
	my $file=shift;
	my $aim_file =shift;

	my %codons=(
	'CTT'=>'L', 'CTC'=>'L', 'CTA'=>'L', 'CTG'=>'L',
	'GTT'=>'V', 'GTC'=>'V', 'GTA'=>'V', 'GTG'=>'V',
	'TCT'=>'S', 'TCC'=>'S', 'TCA'=>'S', 'TCG'=>'S',
	'CCT'=>'P', 'CCC'=>'P', 'CCA'=>'P', 'CCG'=>'P',
	'ACT'=>'T', 'ACC'=>'T', 'ACA'=>'T', 'ACG'=>'T',
	'GCT'=>'A', 'GCC'=>'A', 'GCA'=>'A', 'GCG'=>'A',
	'CGT'=>'R', 'CGC'=>'R', 'CGA'=>'R', 'CGG'=>'R',
	'GGT'=>'G', 'GGC'=>'G', 'GGA'=>'G', 'GGG'=>'G'
	);
	my $i=0;
	my ($num_species,$length_seq);
	my (@seq,@name);
	open IN,$file or die "fail to open $file\n";
	while(<IN>){
        	chomp;
	        if(/(\d+)\s+(\d+)/){
			$num_species=$1;
			$length_seq=$2;
        	        next;
	        }
        	my @temp=split;
	        $seq[$i]=$temp[1];
        	$name[$i]=$temp[0];
	        $i++;
	}
	close IN;

	my @out; 
	for(my $j=0;$j<$length_seq;$j+=3){
        	my @codon=();
		my @site=();
		my @first2=();
	        my $permi="y";
	        for(my $i=0;$i<$num_species;$i++){
        	        $codon[$i]=uc(substr($seq[$i],$j,3));
	                $site[$i]=uc(substr($seq[$i],$j+2,1));
	                $first2[$i]=uc(substr($seq[$i],$j,2));
        	        if($i>0 and $first2[$i] ne $first2[$i-1]){
	                        $permi="n";
                        	last;
                	}
        	        if(! exists $codons{$codon[$i]}){
	                        $permi="n";
                        	last;
                	}


        	}
        	if($permi eq "y"){
	                for($i=0;$i<$num_species;$i++){
                        	$out[$i].=$site[$i];
                	}
        	}
	
	}
	my $length=length$out[0];
	open IN, ">$aim_file.4d" or die;
	print IN "$num_species  $length\n";
	for(my $i=0;$i<$num_species;$i++){
		print IN "$name[$i]  $out[$i]\n";
	}
	close IN;
	"$aim_file.4d";
}



## sub 2 
## produce interleave formt
sub interleave_readseq{
	my $file=shift;

	open IN,"$file" or  die "fail to open $file\n";
	my @philip=<IN>;
	close IN;

	my @aim;
	my $first=shift @philip;
	$first=~ s/(\d+)\s+(\d+)/ $1 $2/;
	push @aim,$first;

	my (@seq,@gene_name);
	foreach (@philip){
		my @temp=split /\s+/,$_;
		push @gene_name,$temp[0];
		push @seq,$temp[1];
	}


	my $k=0;
	my $long=length $seq[0];
	for (my $i=0;$i<$long;$i+=50){
        	foreach my $line(@seq){
	                chomp $line;
        	        if ($i==0){
        	                my $chang=substr($line,$i,50);
	                        1 while($chang=~ s/((?:\w|-){10})((?:\w|-){10})/$1 $2/);
                       		 push @aim,"$gene_name[$k]        $chang";
				$k++;
	                }else{
                        	my $chang=substr($line,$i,50);
                	        my $end;
        	                my @tempt;
	                        for (my $j=0;$j<50;$j+=10){
                        	        my $sub=substr($chang,$j,10);
                	                push @tempt,$sub;
        	                }
	                        $end=join " ", @tempt;
                        	push @aim,"             $end";
	                }
        	}
	        push @aim,"\n";
        	#$k++;if ($k==6){last;}
	}
	open IN ,">$file.interleave";
	foreach (@aim){
	        chomp;
        	print IN "$_\n";
	}
	close IN;
	"$file.interleave";
}


## sub 3
## nex production
sub nex_produce{
	my $file=shift;

	open IN,$file or die "fail to open $file\n";
	open OUT, ">$file.nex" or die "";
	my $i=0;
	my @name;
	while(<IN>){
                chomp;
                if(/\d\s+\d/){
                        my @temp=split;
                        print OUT "#NEXUS\n\nbegin data;\ndimensions ntax=$temp[0] nchar=$temp[1];\nformat datatype=dna interleave=yes gap=-;\nmatrix\n";
                        next;
                }
                if(/^\w/){
                        my @temp=split;
                        $name[$i++]=$temp[0];
                        print OUT "$_\n";
                        next;
                }
       		if(/^\s+\w|-/){
                	print OUT "$name[0]  $_\n";
	                for(my $i=1;$i<@name;$i++){
                	        $_=<IN>;chomp;
                        	print OUT "$name[$i]  $_\n";
        	        }
	                next;
        	}
	        print OUT "$_\n";
	}
	close IN;
	print OUT ";\nend;\n";
	$file=~ s/.*\/([^\/]+$)/$1/;
	print OUT <<"_EOT_";
begin mrbayes;
       	[The following line is useful for automatic execution with no
         warnings issued before files are overwritten and automatic
       	 termination of chains after the prespecified number of generations.]
        set autoclose=yes nowarn=yes;

       	[Set a GTR + gamma +I model for all partitions]
        lset nst=6 rates=invgamma;
        
        mcmc ngen=1000000 printfreq=100 samplefreq=100 nchains=4 savebrlens=yes;
       	sumt filename=$file.nex contype=allcompat burnin=3000;

end;


_EOT_


	close OUT;
	"$file.nex";
}


## sub 4
## produce phase 1
sub phase_1_extract
{
	my $file=shift;
	my $aim_file =shift;

	my ($length,$num_species);
	my (@name,@seq);
	open IN,$file or die "";
	my $i=0;
	while(<IN>){
        	chomp;
	        if(/\d\s+\d/){
	                my @temp=split;
        	        $length=$temp[1];
			$num_species=$temp[0];
                	next;
	        }
	        my @temp=split;
	        $seq[$i]=$temp[1];
        	$name[$i]=$temp[0];
	        $i++;
	}
	close IN;

	my (@out,@site);
	for(my $j=0;$j<$length;$j+=3){
		@site=();
	        for(my $i=0;$i<$num_species;$i++){
	                $site[$i]=uc(substr($seq[$i],$j+1,1));
	        }
                for(my $i=0;$i<$num_species;$i++){
                        $out[$i].=$site[$i];
                }
        }

	open IN,">$aim_file.phase1" or die;	
	$length=length$out[0];
	print IN "$num_species  $length\n";
	for(my $i=0;$i<$num_species;$i++){
		$out[$i] =~ s/N|n/-/g;
        	print IN "$name[$i]  $out[$i]\n";
	}
	close IN;
	"$aim_file.phase1";
}


## sub 5
## 
sub RY_coding_file
{
        my $file=shift;
        my $aim_file =shift;

	open IN,$file or die "Fail to open $file\n";
	open OUT, ">$aim_file.RY" or die;
	my $head = <IN>;
	print OUT $head;
	while (<IN>)
	{
		chomp;
		my ($id,$seq) = (split)[0,1];
		$seq =~ tr/AG/R/;
		$seq =~ tr/TC/Y/;
		print OUT "$id  $seq\n";
	}
	close IN;
	close OUT;
	"$aim_file.RY";
}
