#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Long;

my ($input,$help);
GetOptions(
	"input:s"=>\$input,
	"help"=>\$help,
);
if(!$input or $help){usage();exit;}
if(!open IN1,"$input"){print "Error:The input file can not be open\n";usage();}
my $base_name=$input;
my %hash_fa;
my %hash_identity;
my $id='';
####read fa file
while(<IN1>){
	if(/>(\S+)/){$id=$1;next;}
	chomp;
	s/\s//g;
	$hash_fa{$id}.=$_;
}
close IN1;
my %hash_out1;
my @id=sort keys %hash_fa;
my $len=length($hash_fa{$id[1]});
my @removed=();
####### get the specific block
for(my $k=0;$k<$len;$k++){
        my $allgaps = 1;
	for(my $i=0; $i<@id; $i++){
                if (substr($hash_fa{$id[$i]},$k,1) !~ m/[Nn-]/) {
			$allgaps=0;
			last;
		}
	}
	if ($allgaps==0){
		for(my $i=0; $i<@id; $i++){
			$hash_out1{$id[$i]}.=substr($hash_fa{$id[$i]},$k,1);
		}
	} else {
		push(@removed, $k);	
	}
}


############# put out 
#print_pos(\%hash_out2,"$base_name-$windows-$min_identity.stat.xls");
put_out_fa(\%hash_out1,"$base_name-allgap.filtered");
print "The following sites are removed:\n@removed\n";


###put out the changed fa file. specific block masked with 'n', low identity masked wtih lower case forms
sub put_out_fa{
	my ($hash,$out)=@_;
	if($out){open OUT,">$out";}
	foreach my $id(sort keys %{$hash}){
		if($out){print OUT ">$id\n$hash->{$id}\n";}
		else{print ">$id\n$hash->{$id}\n";}
		}
	if($out){close OUT;}
}

sub usage{
	print <<USAGE;
	This program is used to mask the specific and low identity sequences of multiple sequence alignment in FASTA format.
	
	perl $0 --input <input.fa>;
	or perl $0 -i <input.fa>; 

	--input(i): multiple sequence alignment in FASTA format;
	
	The output file: <input>.flitered:alignment file after removing and outputs filtering information to standard output;
	
USAGE
	}
