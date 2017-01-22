#!/usr/bin/perl

use strict;
use CGI;
use CGI::Session;
use CGI::Carp qw(fatalsToBrowser);


my $session = new CGI::Session;
$session->load();
$session->delete();
$session->flush();
print $session->header(-location => "index.cgi");