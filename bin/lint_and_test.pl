#!/usr/bin/perl

#run jslint and get output
$lint=`jslint4vim @ARGV`;
if ($lint =~ /jslint\:\sNo\sproblems\sfound\./) {
	$results=`run_jstests`;
	print $results;
} else {
	print $lint;
}
