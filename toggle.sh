#!/bin/bash

banHost="foo1.example.com,foo2.example.com"

function isRoot() {
    me=`id -u`
    root=`id -u root`
    if [ $me -ne $root ]; then
	echo root permission required.
	    return 0
    else
	return 1
    fi
}

function off() {
    cmd="ipfw -q add"
    ks="keep-state"
    $cmd 1 check-state
    # Flush all rules
    ipfw -q flush

    index=1
    for str in $(echo $banHost | tr "," "\n")
    do
	$cmd $index deny all from any to $str out setup $ks
	let index++
    done

    let index--
    echo -n "Blocked $index host"
    if [ $index -gt 1 ]; then
	echo "s"
    fi
}

function on() {
    cmd="ipfw -q delete"

    index=1
    for str in $(echo $banHost | tr "," "\n")
    do
	$cmd $index
	let index++
    done

    let index--
    echo -n "Unlocked $index host"
    if [ $index -gt 1 ]; then
	echo "s"
    fi
}

function firewall() {
    case $1 in
	'on' )
	on
	;;
    'off' )
	off
	;;
    esac
}

isRoot
if [ $? -eq 0 ]; then
    exit
else
    if [ -z $1 ]; then
	echo "$0 [on | off]"
	echo "Toggle network connection ability [on | off]."
	echo
	exit
    else
	firewall $1
    fi
fi
