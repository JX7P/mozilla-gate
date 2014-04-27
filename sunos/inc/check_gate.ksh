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

is_git_repo() 
{
	git_repo=$1
	if git rev-parse --git-dir > /dev/null 2>&1; then
	return 0
	else
	err "${git_repo} is NOT a valid git repository"
	return 1
	fi
}

# verify this checkout of the gate looks sane
check_gate() 
{

	[ -d "${MOZILLA_WS}sunos" ] || err "MOZILLA_WS \"$MOZILLA_WS\" is not correctly set"
	[ -n "$EMAIL" ] || err "EMAIL was not set"
	[ -n "$EDITOR" ] || err "EDITOR was not set"

	gates=$1

	[ -n "$gates" ] || gates="$all_gates"

	for gate in $gates; do
	[ -d "${MOZILLA_WS}${gate}" ] || err "dir \"${MOZILLA_WS}${gate}\" does not exist"
	#is_git_repo $gate
	done
}
