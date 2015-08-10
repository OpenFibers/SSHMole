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
#connection error
		"?sh: Error*" {puts "CONNECTION_ERROR"; exit};
#connection refused
        "*onnection refused*" {puts "CONNECTION_REFUSED"; exit};
#host error
		"*o route to host*" {puts "NO_ROUTE_TO_HOST"; exit};
#host key verification failed
        "*ey verification failed*" {puts "HOST_KEY_VERIFICATION_FAILED"; exit};
#forwarding port error
		"*ad dynamic forwarding specification*" {puts "BAD_DYNAMIC_FORWARDING_SPECIFICATION"; exit};
        "*rivileged ports can only be forwarded by root*" {puts "PRIVILEGED_DYNAMIC_PORTS_UNAVAILABLE"; exit};
        "*annot listen to port*" {puts "DYNAMIC_PORTS_USED"; exit};
#remote port error
		"*ad port*" {puts "BAD_REMOTE_PORT"; exit};
        "*onnection closed by remote host*" {puts "REMOTE_PORT_SHUT_DOWN"; exit};
#syntax error
        "*sage*" {puts "SSH_SYNTAX_ERROR"; exit};
#broken pipe
        "*roken pipe*" {puts "BROKEN_PIPE"; exit};

#bot answers
		"*yes/no*" {send "yes\r"; exp_continue};
		"*?assword:*" {	send "$password\r"; set timeout 4;
						expect "*?assword:*" {puts "WRONG_PASSWORD"; exit;}
					  };
}

puts "CONNECTED";
set timeout -1
expect eof;

