#!/usr/bin/env perl
use Data::Dumper;
#scrape a Ext 4 class definition file for dependencies
#the file may be given as an argument or STDIN
my @lines = <>;
#get hash of dependencies 
my $class_deps = parse_class_lines(\@lines);
#get flattened array ref of dependecies
my $class_deps_arr = get_deps_array($class_deps);
#now that we have the immediate dependencies of the file we were given
#we must lookup the files where those classes are defined and get theirs
#this is represented as a hash (%sub_deps) of ClassName => [deps]
my %sub_deps = ();

#handle paths: TODO: parse paths [] declaration  in Ext.Loader.setConfig()
#currently we assume that current directory + class name with . replaced with / is correct path
my $base_path = `pwd`;
chomp ($base_path);

foreach (@$class_deps_arr) {
	print "processing $_ \n";
	$sub_deps{$_} = get_file_deps(get_file_path($_));
}

#DEBUG
print Dumper(\%sub_deps);

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
			if(exists $sub_deps{$_}) {
				print "skipping $_ \n";
				next;
			} else {
				print "recursing for $_...\n";
				#only find deps if not already indexed
				$sub_deps{$_} = get_file_deps(get_file_path($_));
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
