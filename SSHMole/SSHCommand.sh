#!/usr/bin/expect -f
#!/bin/sh

set arguments [lindex $argv 0]
set password [lindex $argv 1]

eval spawn $arguments

match_max 100000

set timeout 1
#expect  "*yes/no*" {send "yes\r"; exp_continue};

set timeout -1
expect {
		"?sh: Error*" {puts "CONNECTION_ERROR"; exit};
		"*o route to host*" {puts "NO_ROUTE_TO_HOST"; exit};
		"*ad dynamic forwarding specification*" {puts "BAD_DYNAMIC_FORWARDING_SPECIFICATION"; exit};
		"*sage*" {puts "SSH_SYNTAX_ERROR"; exit};
		"*ad port*" {puts "BAD_LOCAL_PORT"; exit};
		"*Connection refused*" {puts "CONNECTION_REFUSED"; exit};
		"*yes/no*" {send "yes\r"; exp_continue};
		"*?assword:*" {	send "$password\r"; set timeout 4;
						expect "*?assword:*" {puts "WRONG_PASSWORD"; exit;}
					  };
}

puts "CONNECTED";
set timeout -1
expect eof;

