#!/usr/bin/perl

package firewall;
use strict;

#FIXME need snat for dnat to work, syntax may change

%firewall::dnat = (
#	forward_https => { source_interface => "external", source_port => 8080, protocol => "tcp", destination => "192.168.0.5:8080" }
);

return 1;
