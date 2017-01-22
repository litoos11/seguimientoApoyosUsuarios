#! /usr/bin/perl -w
package ConectarDB;

use strict;
use DBI;

#variables
my $dbname = 'apoyos_usuarios';
my $dbhost = '127.0.0.1';
my $dbuser = 'root';
my $dbpwd  = '';

my $q_string = "DBI:mysql:host=$dbhost;database=$dbname";

sub connect {
	return (DBI->connect($q_string,$dbuser,$dbpwd,{
		mysql_enable_utf8 =>1,
		PrintError        =>0,
		RaiseError        =>1
		# ShowErrorStatement => 1
		# HandleError=>\&dbi_error_handler

		}));
}

# sub dbi_error_handler{
# 	my($mensage, $handle, $primer_valor) = @_;

# 	print "Error: $mensage\n";
# 	return 1;
# }
1;