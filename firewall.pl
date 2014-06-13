#!/usr/bin/perl
# TODO implement proper snat

package firewall;

require "config/ifaces.pl";
require "config/masquerade.pl";
require "config/services.pl";
require "config/dnat.pl";

use strict;

my $iptables = "/usr/sbin/iptables";

sub enable_forwarding {
	print STDERR "[enable_forwarding]\n";
	print "echo \"1\" > /proc/sys/net/ipv4/ip_forward\n";
}


sub flush_iptables {
	print STDERR "[flush_iptables]\n";

	print "iptables -F\n";
	print "iptables -X\n";
	print "iptables -t nat -F\n";
	print "iptables -t nat -X\n";
}

sub allow_existing_connections {
	print STDERR "[allow_existing_connections]\n";

	print "iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n";
	print "iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT\n";
	print "iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT\n";
}

sub setup_masquerading {
	print STDERR "[setup_masquerading]\n";

	for my $rule (keys %firewall::masquerade) {
		for my $source_iface (@{ $firewall::interfaces{$firewall::masquerade{$rule}{source}} }) {

			print "iptables -t nat -A POSTROUTING -o $source_iface -j MASQUERADE\n";

			for my $destination_iface (@{ $firewall::interfaces{$firewall::masquerade{$rule}{destination}} }) {
				print STDERR "[setup_masquerading] [$rule] $source_iface, $destination_iface\n";

				print "iptables -A FORWARD -i $source_iface -o $destination_iface -m state --state ESTABLISHED,RELATED -j ACCEPT\n";
				print "iptables -A FORWARD -i $destination_iface -o $source_iface -j ACCEPT\n";
				print "iptables -A FORWARD -j LOG\n";
			}
		}
	}
}

sub setup_services {
	print STDERR "[setup_services]\n";

	for my $rule (keys %firewall::services) {
		for my $source_iface (@{ $firewall::interfaces{$firewall::services{$rule}{source}} }) {
			print STDERR "[services] allow [$rule] $source_iface $firewall::services{$rule}{protocol} port $firewall::services{$rule}{port}\n";

			print "iptables -A INPUT -p $firewall::services{$rule}{protocol} --dport $firewall::services{$rule}{port} -i $source_iface -j ACCEPT\n";
		}
	}
}

sub setup_internal_interfaces {
	print STDERR "[setup_internal_interfaces]\n";

	for my $source_iface (@{ $firewall::interfaces{internal} }) {
		print STDERR "[setup_internal_interfaces] allow $source_iface\n";

		print "iptables -A INPUT -i $source_iface -j ACCEPT\n";
		print "iptables -A OUTPUT -o $source_iface -j ACCEPT\n";
	}
}

sub setup_external_interfaces {
	print STDERR "[setup_external_interfaces]\n";

	for my $source_iface (@{ $firewall::interfaces{external} }) {
		print STDERR "[setup_external_interfaces] allow $source_iface\n";
		print "iptables -A OUTPUT -o $source_iface -j ACCEPT\n";
	}
}

sub setup_dnat {
	print STDERR "[setup_dnat]\n";

	for my $rule (keys %firewall::dnat) {
		for my $source_iface (@{ $firewall::interfaces{$firewall::dnat{$rule}{source_interface}} }) {
			print STDERR "[dnat] [$rule] $source_iface $firewall::dnat{$rule}{protocol} $firewall::dnat{$rule}{source_port} $firewall::dnat{$rule}{destination}\n";

			print "iptables -A INPUT -p $firewall::dnat{$rule}{protocol} --dport $firewall::dnat{$rule}{source_port} -i $source_iface -j ACCEPT\n";
			print "iptables -t nat -A PREROUTING -p $firewall::dnat{$rule}{protocol} -i $source_iface --dport $firewall::dnat{$rule}{source_port} -j DNAT --to $firewall::dnat{$rule}{destination}\n";
		}
	}
}

sub misc_pppoe_large_frames {
	print STDERR "[misc_pppoe_large_frames]\n";
	print "iptables -A OUTPUT -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu\n";
	print "iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu\n";
}

flush_iptables;
enable_forwarding;
setup_internal_interfaces;
setup_external_interfaces;
allow_existing_connections;
misc_pppoe_large_frames;
setup_masquerading;
setup_services;
setup_dnat;
