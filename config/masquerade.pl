#!/usr/bin/perl

package firewall;
use strict;

%firewall::masquerade = (
	allow_external => { source => "external", destination => "masquerade" }
);

return 1;
