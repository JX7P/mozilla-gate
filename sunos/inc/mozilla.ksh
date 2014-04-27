#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2009 Sun Microsystems, Inc. All rights reserved.
# Copyright 2014 David Mackay. All rights reserved.
# Use is subject to license terms.
#

all_gates="comm-release"


err() 
{
	echo "$@" >&2
	exit 1
}

derr() 
{
	echo "$@" >&2
	[ "$dryrun" = "y" ] || exit 1
}

msg() 
{
	echo "---- $@ ----"
}

warn() 
{
	echo "$@" >&2
}

ask() 
{
	msg=$1

	echo $msg
	read answer
	case "$answer" in
	y|Y|yes)
	return 1
	;;
	*)
	return 0
	;;
	esac
}

. sunos/inc/check_gate.ksh


init_build() 
{
	unset MAKEFLAGS || true
	unset LD_LIBRARY_PATH || true

	if [ -d $MOZILLA_WS ]
	then
	export proto=${MOZILLA_WS}/proto/install
	else
	export proto=${MOZILLA_WS}proto/install
	fi

	export PATH=/usr/bin/:/bin:/usr/sbin:/usr/sfw/bin:/usr/perl5/bin:/usr/gnu/bin
	export MAKE=/usr/sfw/bin/gmake
	export PYTHON=/usr/bin/python2.7

	# Reset all locale-type variables
	export LANG=C
	export LC_COLLATE=C
	export LC_CTYPE=C
	export LC_MESSAGES=C
	export LC_MONETARY=C
	export LC_NUMERIC=C
	export LC_TIME=C

	if [ -z "$1" -o "$1" = "debug" ]; then
	export debug="y"
	export debugsuffix="-debug"
	export CFLAGS="$cflags_common $cflags_debug"
	export LDFLAGS="$ldflags_common $ldflags_debug"
	export CONFFLAGS="$confflags_common $confflags_debug"
	else
	export debug="n"
	export debugsuffix=""
	export CFLAGS="$cflags_common $cflags_nondebug"
	export LDFLAGS="$ldflags_common $ldflags_nondebug"
	export CONFFLAGS="$confflags_common $confflags_nondebug"
	fi

	export objdir="build/$COMPONENT$debugsuffix"
	export staging="proto/staging$debugsuffix"

	msg "staging dir: ${staging}"

}


do_getopts() 
{
	skip_prepare=""
	incremental=""

	while getopts m:is name
	do
	case $name in
	i) incremental="-i"
		                 skip_prepare="-s"
	;;
		                s) skip_prepare="-s"
	;;
	?) usage
	;;
	esac
	done

	optind=$OPTIND

	export skip_prepare
	export incremental
	export optind
}

no_prefix() 
{
	echo $@ | awk -F+ '{print $NF}'
}

append_slash() 
{
	if echo $1 | grep '/$' 2>&1 > /dev/null; then
	echo $1
	else
	echo $1/
	fi
}

isdebug()
{
	if [ $debug == "y" ]; then
		echo "isdebug yes"
		return 1
	else
		return 0
	fi
}

autogen()
{
	cd $gatepath

	if [ -a "autogen.sh" ]; then
		./autogen.sh
	else
		automake --add-missing
		autoreconf -f
	fi
}

configureit()
{
	mkdir -p $objdir
	cd $objdir
	msg "configuring ${COMPONENT}"
	$gatepath/configure $CONFFLAGS
}

packageit()
{
	msg "packaging ${COMPONENT}"
	cd ${MOZILLA_WS}sunos/pkg/${COMPONENT}
	mkdir -p ${MOZILLA_WS}packages
	pkgmk -o -b ${MOZILLA_WS}${staging} -f proto -d ${MOZILLA_WS}packages
}	 

if [ -d "${MOZILLA_WS}" ] ; then
	export MOZILLA_WS=${MOZILLA_WS}/
fi

[ -n "$MOZILLA_WS" -a -d "${MOZILLA_WS}sunos/" ] || {
	echo "MOZILLA_WS is not set correctly" >&2
	echo "${MOZILLA_WS}sunos/ must exist" >&2
	exit 1
}

. sunos/inc/proto_ops.ksh
