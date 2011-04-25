#!/usr/bin/env perl
use Data::Dumper;
#scrape a Ext 4 class definition file for dependencies
#the file may be given as an argument or STDIN
my @lines = <>;

my $class_deps = parse_class_lines(\@lines);
#now that we have the immediate dependencies of the file we were given
#we must lookup the files where those classes are defined and get theirs
#this is represented as a hash of ClassName => [deps]
my %sub_deps = ();

foreach (@$class_deps) {
	print "getting deps for class: $_ \n";
}
#print Dumper(get_deps_array($class_deps));

#TODO: process files recursively

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
		@split_deps = split(/\s*\,\s*/, $1);
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
