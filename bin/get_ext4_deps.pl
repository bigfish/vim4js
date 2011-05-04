#!/usr/bin/env perl
use Data::Dumper;
#scrape a Ext 4 app .html file with a require() statement, and optionally a paths declaration
#part the first:: scrape the HTML file for paths and requires
#my $base_path = `pwd`;
#chomp ($base_path);
my %paths = ();
my %files = ();
my @requires = ();
my $in_config = 0;
my $in_paths = 0;

while (<>) {
	if ($_ =~ /Ext.Loader.setConfig\(\{/) {
		$in_config = 1;
	}
	if ($_ =~ /\<\/script/) {
		$in_config = 0;
	}
	#assume jslint compliant formatting
	if ($in_config and $_ =~ /^\s*paths\s*\:\s*\{\s*$/ ) {
		$in_paths = 1;
	}
	if($in_paths and $_ =~ /^\s*\}\,?\s*$/) {
		$in_paths = 0;
	}
	if($in_paths) {
		if ($_ =~ /^\s*['"]([^'"]*)['"]\s*\:\s*['"]([^'"]*)['"]\,?\s$/) {
			$paths{$1} = $2;
		}
	}
	if($_ =~ /Ext\.require\(([^)]*)\)/) {
		#normalize array
		my $required = $1;
		if ($required =~ /\s*\[([^]]*)\]\s*/) {
			$required = $1;
			if($required =~ /\,/) {
				my @required = split(/\s*\,\s*/, $required);
				push(@requires, @required);
			} else {
				push(@requires, $required);
		   }	
		} else {
			push(@requires, $required);
		}
	}
}
#print Dumper(\%paths);

my %sub_deps = ();
my @all_deps = () ;

@requires = map { strip_quotes($_) } @requires;

#get dependencies recursively for each required class
foreach $require(@requires) {
	$sub_deps{$require} = dedupe_array( get_file_deps( get_class_path($require)));
	push @all_deps, @{$sub_deps{$require}}
}

#add the requires as dependencies also
push (@all_deps, @requires);

$all_deps = dedupe_array(\@all_deps);

#sort dependencies so they are in order 
my $sorted_deps = $all_deps;
#print Dumper($sorted_deps);
my $last_result = '';

while( $last_result ne join(':', @$sorted_deps)) {
	$last_result = join(':', @$sorted_deps);
	foreach(@$all_deps) {
		$sorted_deps = insert_class_into_deps($sorted_deps, $_);
	} 
}
# output file paths in required order
print map { $files{$_} . " " } @$sorted_deps;

#DEBUG
#print Dumper(\%sub_deps);
#print Dumper(\@all_deps);
#print Dumper(\%files);
#print Dumper($sorted_deps);

################################### FUNCTIONS ############################

#insert given class at correct position so its dependencies are satisfied
sub insert_class_into_deps
{
	my $deps_arr = shift;
	my $class_name = shift;
	my $classes = remove_from_array($deps_arr, $class_name);
	my $class_deps = $sub_deps{$class_name};
	my $pos = 1;
	my @previous_classes;
	my $num_classes = scalar @$classes;
	#if no deps, put at start of array
	if(!scalar @$class_deps) {
		unshift(@$classes, $class_name);
	} else {
		foreach (@$classes) {
			if ($pos >= $num_classes) {
				die "unable to satisfy dependencies of $class_name \n";
			}
			@previous_classes = @$classes[0..$pos];
			#if any are missing, try next position
			if(!has_depends(\@previous_classes, $class_name)) {
				$pos++;
				next;
			} else {
				#print "satisfied all dependencies for $class_name \n";
				last;
			}
		}
		my $idx = $pos + 1;
		#pos is the correct position for this class - insert it there
		splice @$classes, $idx, 0, $class_name;
		#print "added $class_name at POS: $idx\n";
	}
	return $classes;
}

sub has_depends
{
	my $depends = shift;
	my $class_name = shift;
	my $class_deps = $sub_deps{$class_name};
	foreach $dep (@$class_deps) {
		if(!in_array($depends, $dep)) {
			#print "$dep is not satisfied \n";
			return 0;
		}
		#print "satisfied dependency: $dep  for $class_name \n";
	}
	return 1;
}

sub in_array
{
	my $array = shift;
	my $item = shift;
	undef %is_in_array;
    for (@$array) { $is_in_array{$_} = 1 }
	return $is_in_array{$item};
}

sub remove_from_array
{
	my $arr = shift;
	my $item = shift;
	my @new = @$arr;
	my $len = @new;
	for (0..$len) {
		if ($new[$_] eq $item) {
			splice @new, $_, 1;
			return \@new;
		}
	}
	print "error in remove_from_array: did not find $item in @new \n";
}

sub get_class_path
{
	my $class_name = shift;
	my $class_path = $class_name;

	if(exists $files{$class_name}) {
		return $files{$class_name};
	} else {
		#replace . with / in $class
		$class_path =~ s/\./\//g;
		#expand paths from package names
		foreach $cls (keys %paths) {
			$class_path =~ s/$cls/$paths{$cls}/;
		}
		#$class_path = "$base_path/$class_path.js";
		$class_path = "$class_path.js";
		#cache in files hash
		$files{$class_name} = $class_path;
		return $class_path;
	}
}

sub dedupe_array
{
	my $arr = shift;
	my %seen = ();
	my @uniq = ();
   	foreach $item (@{$arr}) {
   		push(@uniq, $item) unless $seen{$item}++;
   	}
	return \@uniq;
}

sub get_file_deps
{
	my $file_path = shift;
	open CLASS_FILE, '<', $file_path;
	my @lines = <CLASS_FILE>;
	close CLASS_FILE;
	my $class_deps = parse_class_lines(\@lines);
	my $class_deps_arr = get_deps_array($class_deps);
	#recurse
	if(scalar @$class_deps_arr) {
		foreach (@$class_deps_arr) {
			my $deps;
			if(exists $sub_deps{$_}) {
				$deps = $sub_deps{$_};
				next;
			} else {
				#only find deps if not already indexed
				$deps = get_file_deps(get_class_path($_));
				#add to global index
				$sub_deps{$_} = $deps;
				#add to deps array which will be returned for this class 
				push @$class_deps_arr, @$deps;
			}
		}
	}
	return $class_deps_arr;
}

sub get_file_path
{
	my $class_path = shift;
	$class_path =~ s/\./\//g;
	return "$base_path/$class_path.js";
}

sub get_deps_array
{
	#gets deps info hash as argument
	my $deps = shift;
	my @deps_arr = ();

	if ($deps->{extends}) {
		push(@deps_arr, $deps->{extends});
	}
	if ($deps->{requires}) {
		push(@deps_arr, @{$deps->{requires}});
	}
	if ($deps->{mixins}) {
		push(@deps_arr, @{$deps->{mixins}});
	}
	if ($deps->{uses}) {
		push(@deps_arr, @{$deps->{uses}});
	}
	return \@deps_arr;
}

sub parse_class_lines
{
	my %deps = ();
	#gets array reference
	my $lines = shift;
	foreach (@$lines) {
		#get superclass from extends: statement
		if($_ =~ /extend\s*\:\s*['"]([^'"]*)['"]/) {
			$deps{'extends'} = $1;
		} elsif ($_ =~ /^\s*(requires|uses|mixins)\s*\:\s*\[([^]]*)\]/) {
			$deps{$1} = parse_deps($2);
		}
	}
	return \%deps;
}

sub parse_deps
{
	my $deps_str = shift;
	my @deps = ();
	my @split_deps;
	#split multiple element array elements on ,
	if($deps_str =~ /\,/) {
		@split_deps = split(/\s*\,\s*/, $deps_str);
		foreach (@split_deps) {
			push(@deps, strip_quotes($_));
		}
	} else {
		#single array element
		push(@deps, strip_quotes($deps_str));
	}
	return \@deps;
}

sub strip_quotes
{
	my $quoted_str = shift;
	if($quoted_str =~ /\s*['"]([^'"]*)['"]\s*/) {
		return $1;
	} else {
		return $quoted_str;
	}
}
