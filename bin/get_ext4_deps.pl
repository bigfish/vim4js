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

#get dependencies recursively for each required class
foreach (@requires) {
	my $require = strip_quotes($_);
	$sub_deps{$require} = dedupe_array( get_file_deps( get_class_path($require)));
	push @all_deps, @{$sub_deps{$require}}
}

$all_deps = dedupe_array(\@all_deps);

#sort dependencies so they are in order from least dependent to most

#get files for dependencies
#my @files = map { get_class_path($_) } @$all_deps;

#DEBUG
print Dumper(\%sub_deps);
#print Dumper(\@all_deps);
print Dumper(\%files);


################################### FUNCTIONS ############################
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
