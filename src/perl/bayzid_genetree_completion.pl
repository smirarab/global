#!/lusr/bin/perl -w

#use lib "/projects/sate3/tools/bin/bioPerl-1.5.2/lib/perl5";
#use lib "/u/bayzid/Research/simulation_study/tools/bioPerl-1.5.2/lib/perl5";

#use lib "/projects/sate3/tools/bin/bioPerl-1.5.1-rc3";
#use lib "/u/bayzid/Research/simulation_study/tools/bioPerl-1.5.1-rc3/";  # eta korte hobe export PERL5LIB=/u/bayzid/Research/simulation_study/tools/bioperl-1.5.1-rc3/

#use lib "/u/bayzid/Research/simulation_study/tools/BioPerl-1.5.9._2/";

#use lib "/u/bayzid/Research/simulation_study/tools/BioPerl-1.6.901/"; #BioPerl-1.6.901
use lib "/projects/sate3/tools/bin/BioPerl-1.6.901/";

use Bio::TreeIO;
use Bio::Tree::TreeFunctionsI;
use strict;
#use Bio::AlignIO;
use warnings;
use Getopt::Long;
use List::MoreUtils qw{ any };  # will be used for checking whether an element is a memeber of a list or not
use List::MoreUtils qw(uniq);

sub create_node_on_branch {
   my $me = shift;
   my $node = Bio::Tree::Node->new();
   $node->branch_length(undef);
   my $anc = $me->ancestor;
   # null anc check is above
   $node->add_Descendent($me);
   $anc->add_Descendent($node);
   $anc->remove_Descendent($me);
   return $node;
}

sub badInput {
  my $message = "Usage: perl $0 script moves back the missing taxa back to the gene trees. genetree file may have multiple gene trees. 
		\n NOTE: BRANCH LENGTH OF THE GENE TREES HAVE TO MENTIONED. OTHERWISE NEW NODE ON A BRANCH CANNOT BE CREATED
	-g=<geneFile>
	-s=<speciesFile>
	-o=<outputFile>
	-op=<option> option 1: complete all trees, opotion 2: complete a particular number of trees; defualt is option 1. if option == 2 then you must give the numberof Trees to be selected. Largest n trees in terms of number of taxa will be selected for completion.
	-n=<numberOfTreesTobeSelected>";
 print STDERR $message;
  die "\n";
}

GetOptions(
	"g=s"=>\my $geneFile,
	"s=s"=>\my $speciesFile,
	"o=s"=>\my $outFile,
	"op=s"=>\my $option,     # option1: complete all trees, opotion 2: complete a particular number of trees
	"n=s"=>\my $no_of_tree,

);

badInput() if not defined $geneFile;
badInput() if not defined $speciesFile;
badInput() if not defined $outFile;
if ($option == 2){badInput()if not defined $no_of_tree;}
if (!$option)
	{
		print "\nYou haven't provided any option. default option will be 1 that means you are going to complete all the gene trees\n";
		$option = 1;
	}

=st
my $in = Bio::TreeIO->new(-file => "$geneFile",
			   -format => 'newick');
my $in1 = Bio::TreeIO->new(-file => "$speciesFile",
			   -format => 'newick');
my $out = Bio::TreeIO->new(-file => ">$outFile",
			    -format => 'newick');


my $stree = $in1->next_tree;
=cut
if ($option == 1){option1($geneFile,$speciesFile, $outFile);}
if ($option == 2){option2($geneFile,$speciesFile, $outFile, $no_of_tree);}

################################ this option2 is for completing a particular number ($no_of_tree) of gene trees

sub option2 {
	my ($geneF, $speciesF, $outF, $no_of_tree) = @_ ;

	my $in = Bio::TreeIO->new(-file => "$geneF",
			   -format => 'newick');
	my $in1 = Bio::TreeIO->new(-file => "$speciesF",
			   -format => 'newick');
	my $out = Bio::TreeIO->new(-file => ">$outF",
			    -format => 'newick');
	my $desired_number = $no_of_tree;  # how many tree we want to complete. the largest (in terms of number of taxa) $desired_number of trees will be completed

	my $stree = $in1->next_tree;

	my @gtrees;

# sorting the trees according to their taxa number
	my $st_time1 = time();
	while( my $gtree = $in->next_tree )
	{
		push (@gtrees, $gtree);
	}
	my %Gtrees;  #for hashing key =  index of a tree, value = taxa count
	
	for (my $i =0; $i <= $#gtrees; $i ++)
#	foreach my $tree(@gtrees)
	{
		#find the number of leaves;
		my @leaves = $gtrees[$i]->get_leaf_nodes;
		my @taxa;
		foreach my $leaf(@leaves)
		{
			push (@taxa, $leaf->id);
		}	
		my @uniq_taxa = uniq(@taxa);   # to remove duplicate. it needs a package List::MoreUtils qw(uniq);
		#my @uniq_taxa=keys %{{ map{$_=>1}@taxa}};   # this can be also used to remove duplicates. multi copy thakte pare emon gene tree er species count ber korar jonno.
		my $taxa_count = scalar (@uniq_taxa);
		#$Gtrees{$gtrees[$i]} = $taxa_count;	# constructing the associative array
		$Gtrees{$i} = $taxa_count;	# constructing the associative array acconding to the index number of a tree in @gtrees and that's leaf count
	}
	
	my @selected_trees;  #it will contain the index of the selected trees
	my $count = $desired_number;
	foreach my $key ( sort { $Gtrees{$a} <=> $Gtrees{$b} } keys %Gtrees )   # sorting descending order. $Gtrees{$a} <=> $Gtrees{$b} will sort it in ascending order (just the order of a and b)
	{	        
		if ($desired_number > 0)
		{
			#print $key, '=', $Gtrees{$key}, $gtrees[$key], "\n";
			push (@selected_trees, $key);  #adding the index of the trees of @gtrees
			
		}
		 $desired_number--;
    	} 
	print "\n\n maximum taxa: $Gtrees{$count}";
	my $end_time1 = time();
	my $run_time1 = $end_time1 - $st_time1;  # time needed for selecting
	print "\n\n TIME NEEDED FOR SELECTING: $run_time1";
# end of sorting and selection.

##### now the completion begins ###############

# finding the set of cluster of species tree
	
	my @stree_clusters = get_all_clades($stree);
	#foreach my $elem (@gene_clusters)
	#{
	#print "\n gene tree clusters: @$elem";	   #printing is tricky
	#}

	foreach my $index (@selected_trees){
	my $gtree = $gtrees[$index];
	#print"\n\n this is the tree: $gtree";
	# first compute the missing taxa.
	my @taxa_gt_id = $gtree->get_leaf_nodes;  # id ..not name
	my @taxa_st_id = $stree->get_leaf_nodes;
	
	my @taxa_gt;  # for name of the taxa
	my @taxa_st;

	foreach my $leaf (@taxa_gt_id)
		{
			my $name = $leaf->id;    # name of the taxa
			push(@taxa_gt, $name);
		}

	foreach my $leaf (@taxa_st_id)
		{
			my $name = $leaf->id;    # name of the taxa
			push(@taxa_st, $name);
		}

	#print "\n @taxa_st";
	
	# calculating the missing taxa
	my %taxa_gt=map{$_ =>1} @taxa_gt;
	my %taxa_st=map{$_ =>1} @taxa_st;

	my @missing_taxa = grep(!defined $taxa_gt{$_}, @taxa_st);
	
	
	#finding the id of the missing taxa given the names
	my @missing_taxa_id;
	foreach my $val (@missing_taxa)
		{
			my $node = $stree->find_node(-id => $val);
			push(@missing_taxa_id, $node);
		}	

	#now maximal missing clade in ST ber korte hobe	
	
	#my @max_missing_clades = get_bmaximal(\@missing_taxa, $stree);  # finding the maximal missing clades in ST
	my @max_missing_clades = get_bmaximal_version2(\@missing_taxa, \@stree_clusters);  # finding the maximal missing clades in ST
	#now insert each maximal missing clade in ST into the gt
	for (my $i = 0; $i <= $#max_missing_clades; $i++ ){

		my $in1_copy = Bio::TreeIO->new(-file => "$speciesFile",   #back-up ta na use korle dekha jai j species tree ta pruned hote thake.
			   -format => 'newick');
		my $stree_backup = $in1_copy->next_tree;

		my $sibling = find_sibling(\@{$max_missing_clades[$i]}, $stree_backup);  # to find the sibling of the missing clade
		
		# now sibling cluster create kora

		my @sib_cluster;
		if ($sibling->is_Leaf) {push (@sib_cluster, $sibling->id);}

		if (!$sibling->is_Leaf)
		{
			my @sib_desc = $sibling->get_all_Descendents;
	
			foreach my $n (@sib_desc)
			{
				if ($n->is_Leaf)
				{
				push (@sib_cluster, $n->id);
				}
			}
		}
		# now sibling cluster er maximal clusters in gt ber korbo.
		#my @b_sib_clusters = get_bmaximal(\@sib_cluster, $gtree);  # all the b-maximal cluster in gt where b = sibling cluster
		my @gtree_clusters = get_all_clades($gtree);
		my @b_sib_clusters = get_bmaximal_version2(\@sib_cluster, \@gtree_clusters); 
		my @b_sib_cluster = @{$b_sib_clusters[0]};                 # since missing clade can be inserted at any of them, I take the first one 
	#	print "\n sibling: @b_sib_cluster"; 
	
		# now insert the missing clade so that @b_sib_cluster bicomes the sibling of the inserted missing clade
	
		my $lca = lca_version3(\@b_sib_cluster, $gtree);   # ((a,b),b) tree te a, b, b er lca ki root hobe? ekhane to a and b er parent nibe. that's why lca_version2 use kora hoise
		my $groot = $gtree->get_root_node;
		my $br_len;	
		if ($groot == $lca) 
		{
			#print "\n lca is the root";
			my $slca = lca(\@{$max_missing_clades[$i]}, $stree_backup);
			$groot->add_Descendent($slca);
			$br_len = $slca->branch_length; 
			my $newnode;
			if (defined($br_len)) { 
				$br_len = $br_len*0.6;
				$newnode = $slca.create_node_on_branch($br_len);
			} else {
				$newnode = create_node_on_branch($slca);  # !!!ATTENTION: branck length jodi gene tree te na thake tahole hobe na!!!!!
			}
			$gtree->reroot($newnode);
		
		}

		if ($groot != $lca) 
		{
			$br_len = $lca->branch_length; 
			my $newnode;
			if (defined($br_len)) { 
				$br_len = $br_len*0.6;
				$newnode = $lca.create_node_on_branch($br_len);
			} else {
				$newnode = create_node_on_branch($lca);
			}
			my $slca = lca(\@{$max_missing_clades[$i]}, $stree_backup);
			$newnode->add_Descendent($slca);
		}

	}
	$out->write_tree($gtree);  #writing the gt into the output file
	#print "\n $gtree";
} #end while

	# newick writer doesn't insert any newline after eache tree. so all the completed gene trees will be written one after another without any new line. so here I modify the file by inserting a new line after each semicolon.

	open(INFO, $outFile);		# Open the file
	my $lines = <INFO>;		# Read it into an array
	close(INFO);
	$lines =~ s/;/;\n/g;
	open(OUT, ">", $outFile) or die "can't open $outFile: $!";
	print OUT "$lines";
	
	my $end_time2 = time();
	my $run_time = $end_time2 - $st_time1;
	print "\n\n TIME NEEDED FOR whole process: $run_time";
	
	print OUT "\n\n TIME NEEDED FOR SELECTING n TREES: $run_time1";
	print OUT "\n\n TIME NEEDED FOR whole process: $run_time";

}

################## this option 1 is for completing all the gene trees  #####################################

sub option1 {
	my ($geneF, $speciesF, $outF) = @_ ;

	my $in = Bio::TreeIO->new(-file => "$geneF",
			   -format => 'newick');
	my $in1 = Bio::TreeIO->new(-file => "$speciesF",
			   -format => 'newick');
	my $out = Bio::TreeIO->new(-file => ">$outF",
			    -format => 'newick');

	my $stree = $in1->next_tree;
	my @stree_clusters = get_all_clades($stree);  #finding the set of clusters

	while( my $gtree = $in->next_tree ){ 

	# first compute the missing taxa.
	my @taxa_gt_id = $gtree->get_leaf_nodes;  # id ..not name
	my @taxa_st_id = $stree->get_leaf_nodes;
	
	my @taxa_gt;  # for name of the taxa
	my @taxa_st;

	foreach my $leaf (@taxa_gt_id)
		{
			my $name = $leaf->id;    # name of the taxa
			push(@taxa_gt, $name);
		}

	foreach my $leaf (@taxa_st_id)
		{
			my $name = $leaf->id;    # name of the taxa
			push(@taxa_st, $name);
		}

	#print "\n @taxa_st";
	
	# calculating the missing taxa
	my %taxa_gt=map{$_ =>1} @taxa_gt;
	my %taxa_st=map{$_ =>1} @taxa_st;

	my @missing_taxa = grep(!defined $taxa_gt{$_}, @taxa_st);
	
	
	#finding the id of the missing taxa given the names
	my @missing_taxa_id;
	foreach my $val (@missing_taxa)
		{
			my $node = $stree->find_node(-id => $val);
			push(@missing_taxa_id, $node);
		}	

	#now maximal missing clade in ST ber korte hobe	
	
#	my @max_missing_clades = get_bmaximal(\@missing_taxa, $stree);  # finding the maximal missing clades in ST
	my @max_missing_clades = get_bmaximal_version2(\@missing_taxa, \@stree_clusters); 

=st
	foreach my $elem (@max_missing_clades)
		{
				print "\n maximal missing clade: @$elem";	#	[ @$aref ]	
		}
=cut

	#now insert each maximal missing clade in ST into the gt
	for (my $i = 0; $i <= $#max_missing_clades; $i++ ){

		my $in1_copy = Bio::TreeIO->new(-file => "$speciesFile",   #back-up ta na use korle dekha jai j species tree ta pruned hote thake.
			   -format => 'newick');
		my $stree_backup = $in1_copy->next_tree;

		my $sibling = find_sibling(\@{$max_missing_clades[$i]}, $stree_backup);  # to find the sibling of the missing clade
		
		# now sibling cluster create kora

		my @sib_cluster;
		if ($sibling->is_Leaf) {push (@sib_cluster, $sibling->id);}

		if (!$sibling->is_Leaf)
		{
			my @sib_desc = $sibling->get_all_Descendents;
	
			foreach my $n (@sib_desc)
			{
				if ($n->is_Leaf)
				{
				push (@sib_cluster, $n->id);
				}
			}
		}
		# now sibling cluster er maximal clusters in gt ber korbo.
		my @b_sib_clusters = get_bmaximal(\@sib_cluster, $gtree);  # all the b-maximal cluster in gt where b = sibling cluster
		my @b_sib_cluster = @{$b_sib_clusters[0]};                 # since missing clade can be inserted at any of them, I take the first one 
	#	print "\n sibling: @b_sib_cluster"; 
	
		# now insert the missing clade so that @b_sib_cluster bicomes the sibling of the inserted missing clade
	
		my $lca = lca_version3(\@b_sib_cluster, $gtree);   # ((a,b),b) tree te a, b, b er lca ki root hobe? ekhane to a and b er parent nibe. that's why lca_version3 use kora hoise
		my $groot = $gtree->get_root_node;
		my $br_len;	
		if ($groot == $lca) 
		{
			#print "\n lca is the root";
			my $slca = lca(\@{$max_missing_clades[$i]}, $stree_backup);
			$groot->add_Descendent($slca);
			$br_len = $slca->branch_length; 
			my $newnode;
			if (defined($br_len)) { 
				$br_len = $br_len*0.6;
				$newnode = $slca.create_node_on_branch($br_len);
			} else {
				$newnode = create_node_on_branch($slca);  # !!!ATTENTION: branck length jodi gene tree te na thake tahole hobe na!!!!!
			}
			$gtree->reroot($newnode);
		
		}

		if ($groot != $lca) 
		{
			$br_len = $lca->branch_length;
			my $newnode;
			if (defined($br_len)) { 
				$br_len = $br_len*0.6;
				$newnode = $lca.create_node_on_branch($br_len);
			} else {
				$newnode = create_node_on_branch($lca);
			}
			my $slca = lca(\@{$max_missing_clades[$i]}, $stree_backup);
			$newnode->add_Descendent($slca);
		}

	}
	$out->write_tree($gtree);  #writing the gt into the output file
	#print "\n $gtree";
} #end while

	# newick writer doesn't insert any newline after eache tree. so all the completed gene trees will be written one after another without any new line. so here I modify the file by inserting a new line after each semicolon.

	open(INFO, $outFile);		# Open the file
	my $lines = <INFO>;		# Read it into an array
	close(INFO);
	$lines =~ s/;/;\n/g;
	open(OUT, ">", $outFile) or die "can't open $outFile: $!";
	print OUT "$lines";

}	
################################## sub-programs #######################

# it finds the sibling of a cluster in a tree.
sub find_sibling {
	my ($clade_ref, $tree) = @_ ;
	my @clade = @{$clade_ref};
			
	# first lca ber kori
	my $lca = lca(\@clade, $tree);

	my $parent = $lca->ancestor;
	my @desc = $parent->each_Descendent;
	my $sibling;	
	foreach my $child (@desc)
		{
			if ($child != $lca){
				$sibling = $child;}
		}
	
return $sibling;
}

# this version will not calculate the set of clades. so for all gene trees, we can now compute the set of clades of the speceist tree once and call this function. the function get_bmaximal first compute the set of clades.

sub get_bmaximal_version2{
	my ($cluster_ref, $clade_ref) = @_;
	my @cluster = @{$cluster_ref};
	my @clades = @{$clade_ref};
	#my @nodes = $tree->get_nodes;

=st
	my(@clades, @clade); # set of all clades
	#finding the set of all clades
	foreach my $n (@nodes) 
	{	
		 my @clade;
	   	 my @desc = $n->get_all_Descendents;
	    	 if ($n->is_Leaf) 
			{
			push (@clade,$n->id);
			#push (@clade,$n);
	   	 	}
	    	else 	{
			my @lvs = grep { $_->is_Leaf } @desc;
			foreach my $elem (@lvs)
				{
					push (@clade, $elem->id);
					#push (@clade, $elem);
				}	
	    		}
		
		push (@clades, [@clade]);
	}
=cut
	
	
	# now B clade ber korbo.  clade in tree - missing_taxa = null hole sheta missing clade
	my(@b_clades, @clade1);
	my %cluster=map{$_ =>1} @cluster;
	foreach my $clade (@clades)
		{
			my @clade1 = @$clade;
			my %clade1=map{$_ =>1} @clade1;
			my @diff = grep(!defined $cluster{$_}, @clade1);
			
			if (!@diff)
				{
					push (@b_clades, [@clade1]);  # inserting the missing clades.
				}
			
		}
=st
	#printing the missing clades	
	foreach my $elem (@b_clades)
		{
				print "\n missing clade: @$elem";	#	[ @$aref ]	
		}
=cut

	# finding the maximal missing clades
	my @max_b_clades;
	my $flag = 1;
	my $size_tmp;
	my $size_tmp1;
	for (my $i = 0; $i <= $#b_clades; $i++)
	    {
		my @tmp =  @{$b_clades[$i]};
		my %tmp=map{$_ =>1} @tmp;
		$size_tmp = scalar (@tmp);
		for (my $j = 0; $j <= $#b_clades; $j++ )
		     {
		      if ($j != $i){	
			my @tmp1 =  @{$b_clades[$j]};
			my %tmp1=map{$_ =>1} @tmp1;
			$size_tmp1 = scalar (@tmp1);

			my @diff = grep(!defined $tmp1{$_}, @tmp);  # tmp -tmp1
			my $diff_size = $size_tmp - $size_tmp1; 
						
			if (!@diff && $diff_size < 0)   # single copy hole r $diff_size use kora lagto na. {a,b,b} - {a,b} = null. but size does matter.
				{
					#print "\nflag is set to zero";
					$flag = 0;
					#last;	     # ei line ta consider korte paro kono error dhora porle			
				}
		     }		
		
                }
		if ($flag == 1) 
			{
				push (@max_b_clades, [@{$b_clades[$i]}]);
			}
		$flag = 1;
	    }	

return @max_b_clades;
}





# finding B-maximal clades in a tree. this version will fist compute the set of clades. however, in version2 the set of clades is given
sub get_bmaximal{
	my ($cluster_ref, $tree) = @_;
	my @cluster = @{$cluster_ref};
	my @nodes = $tree->get_nodes;
	my(@clades, @clade); # set of all clades
	#finding the set of all clades
	foreach my $n (@nodes) 
	{	
		 my @clade;
	   	 my @desc = $n->get_all_Descendents;
	    	 if ($n->is_Leaf) 
			{
			push (@clade,$n->id);
			#push (@clade,$n);
	   	 	}
	    	else 	{
			my @lvs = grep { $_->is_Leaf } @desc;
			foreach my $elem (@lvs)
				{
					push (@clade, $elem->id);
					#push (@clade, $elem);
				}	
	    		}
		
		push (@clades, [@clade]);
	}
	
	
	# now B clade ber korbo.  clade in tree - missing_taxa = null hole sheta missing clade
	my(@b_clades, @clade1);
	my %cluster=map{$_ =>1} @cluster;
	foreach my $clade (@clades)
		{
			my @clade1 = @$clade;
			my %clade1=map{$_ =>1} @clade1;
			my @diff = grep(!defined $cluster{$_}, @clade1);
			
			if (!@diff)
				{
					push (@b_clades, [@clade1]);  # inserting the missing clades.
				}
			
		}
=st
	#printing the missing clades	
	foreach my $elem (@b_clades)
		{
				print "\n missing clade: @$elem";	#	[ @$aref ]	
		}
=cut

	# finding the maximal missing clades
	my @max_b_clades;
	my $flag = 1;
	my $size_tmp;
	my $size_tmp1;
	for (my $i = 0; $i <= $#b_clades; $i++)
	    {
		my @tmp =  @{$b_clades[$i]};
		my %tmp=map{$_ =>1} @tmp;
		$size_tmp = scalar (@tmp);
		for (my $j = 0; $j <= $#b_clades; $j++ )
		     {
		      if ($j != $i){	
			my @tmp1 =  @{$b_clades[$j]};
			my %tmp1=map{$_ =>1} @tmp1;
			$size_tmp1 = scalar (@tmp1);

			my @diff = grep(!defined $tmp1{$_}, @tmp);  # tmp -tmp1
			my $diff_size = $size_tmp - $size_tmp1; 
						
			if (!@diff && $diff_size < 0)   # single copy hole r $diff_size use kora lagto na. {a,b,b} - {a,b} = null. but size does matter.
				{
					#print "\nflag is set to zero";
					$flag = 0;
					#last;	     # ei line ta consider korte paro kono error dhora porle			
				}
		     }		
		
                }
		if ($flag == 1) 
			{
				push (@max_b_clades, [@{$b_clades[$i]}]);
			}
		$flag = 1;
	    }	

return @max_b_clades;
#return @{$max_b_clades[0]};  #jekono ekta pathalei hoi.

}

# finding the lca of a cluster
sub lca{
	my ($clade_ref, $tree) = @_;
	my @clade = @{$clade_ref};
	
	my $cladesize = 0;
	my @cladenodes;
	my $lca;
	foreach my $val (@clade)
		{
		   my $node = $tree->find_node(-id => $val);  # name to actual id map korlam
		   $lca = $node;
		   push(@cladenodes, $node);
		   $cladesize++;

		}
	
#	my $cladesize = scalar (@nodes);
	
	if ($cladesize > 1){
			    $lca = $tree->get_lca(-nodes => \@cladenodes);	
			   }	
return $lca;
}


#this version
sub lca_version2{
	my ($clade_ref, $tree) = @_;
	my @clade = @{$clade_ref};
	
	my $cladesize = 0;
	my @cladenodes;
	my @leaves = $tree->get_leaf_nodes;
	my $lca;
	foreach my $val (@clade)
		{
		   my $node = $tree->find_node(-id => $val);  # name to actual id map korlam
		   $lca = $node;
		   foreach my $leaf (@leaves)
			{		   
			   my $leaf_name = $leaf->id;
			   if ($leaf_name eq $val)    # == dile hobe na...karon == shudhu numeric er case e kaj kore properly
			      {
				   push(@cladenodes, $leaf);
				   $cladesize++;
			      }
			}

		}
	
#	my $cladesize = scalar (@nodes);
	
	if ($cladesize > 1){
			    $lca = $tree->get_lca(-nodes => \@cladenodes);	
			   }	
return $lca;
}

# correctly finds the lca of a cluster that might contain multiple copies from a gene. (a,b,b) er lca emon ekta node jar cluster abb.
sub lca_version3{
	my ($clade_ref, $tree) = @_;
	my @cluster = @{$clade_ref};
	
	my $cladesize = 0;
	my @cladenodes;
	my $lca;
	#finding the set of all clades
	my @nodes = $tree->get_nodes;
	my $is_equal;
	foreach my $n (@nodes) 
	{	
		 my @clade;
	   	 my @desc = $n->get_all_Descendents;
	    	 if ($n->is_Leaf) 
			{
			push (@clade,$n->id);
	   	 	}
	    	else 	{
			my @lvs = grep { $_->is_Leaf } @desc;
			foreach my $elem (@lvs)
				{
					push (@clade, $elem->id);
				}	
	    		}
		$is_equal = cluster_equal(\@clade,\@cluster);
		if ($is_equal == 1)
		{
			return $n;
		}

		
	}

}


sub get_all_clades{
my ($tree) = @_;
my @nodes = $tree->get_nodes;

#print "\nin func: nodes: @nodes";


	my(@clades, @clade); # set of all clades
	#finding the set of all clades
	foreach my $n (@nodes) 
	{	
		 my @clade;
	   	 my @desc = $n->get_all_Descendents;
	    	 if ($n->is_Leaf) 
			{
			push (@clade,$n->id);
			#push (@clade,$n);
	   	 	}
	    	else 	{
			my @lvs = grep { $_->is_Leaf } @desc;
			foreach my $elem (@lvs)
				{
					push (@clade, $elem->id);
					#push (@clade, $elem);
				}	
	    		}
		
		push (@clades, [@clade]);
	}
return @clades;
}

sub cluster_equal{
	my ($clade_ref1, $clade_ref2) = @_;
	my @cluster1 = @{$clade_ref1};
	my @cluster2 = @{$clade_ref2};

	my $flag = 0;
	if (@cluster1 == @cluster2)  #checking the size;
		{
			
			$flag =1;
			foreach my $elem (@cluster1)
				{
					
					if (any { $_ eq $elem} @cluster2) { }   # checking the membership
					else {return 0;}	
				}
		}
	

#	if ($flag == 1) {return 1;}
	return $flag;

}


print "\ndone.\n";
