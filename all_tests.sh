#!/bin/bash
# Assuming your system is only connected with one network
declare source_ip=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'`
declare destination_ip=$2

# the ping test
pingTest(){
	declare cmnd1="$1"
	declare cmnd2="$2"
	declare ret_code1
	declare ret_code2
	eval $cmnd1
	ret_code1=$?
	eval $cmnd2
	ret_code2=$?
	if [ $ret_code1 = 0 ] && [ $ret_code2 = 0 ]; then
		printf "Test Case 1 passed, '%s' can ping '%s' each other. \n" $source_ip, $destination_ip
	elif [ $ret_code1 != 0 ]; then
		printf "Error : [%d], Test Case 1 failed, '%s' can't ping '%s'. \n" $ret_code1, $source_ip, $destination_ip
		exit $ret_code1
	else
		printf "Error : [%d], Test Case 1 failed, '%s' can't ping '%s'. \n" $ret_code2, $destination_ip, $source_ip
		exit $ret_code2
	fi;
}

ipForward(){
	declare cmnd="$*"
	declare val=`eval $cmnd`
	if [ $val = 1 ]; then
		printf "Test Case 2 passed, forwarding is enabled between '%s' and '%s'. \n" $source_ip, $destination_ip
	else
		printf "Error : [%d], Test Case 12 failed, IP forwarding is disabled \n" $ret_code2
	fi;
}

traceRoute(){
	declare cmnd="$*"
	declare ret_code
	eval $cmnd
	ret_code=$?
	if [ $ret_code = 1 ]; then
		printf "Test Case 3 passed, tracing packet from '%s' to '%s'", $source_ip, $destination_ip
	else
		printf "Error : [%d], Test Case 3 failed, packets cannot reach to '%s'. \n" $ret_code1, $destination_ip
		exit $ret_code
	fi;
}

command1="ping -I $source_ip $destination_ip -c 1 >/dev/null"
command2="ping -I $destination_ip $source_ip -c 1 >/dev/null"
pingTest "$command1" "$command2"

command3="sysctl net.ipv4.ip_forward >/dev/null"
ipForward "$command3"

command4="traceroute $destination_ip | grep -Eo '!H|\*'"
traceRoute "$command4"

#telnet should be activated in the router
#shares the data in plain text
#have to provide port
command5=""