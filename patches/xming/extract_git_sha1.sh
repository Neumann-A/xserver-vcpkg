#!/bin/sh
if [ ! -f hw/xwin/git_sha1.h ]; then
	touch hw/xwin/git_sha1.h
fi

if [ ! -d .git ]; then
	exit
fi

if which git > /dev/null; then
    # Extract the 7-digit "short" SHA1 for the current HEAD, convert
    # it to a string, and wrap it in a #define.  This is used in
    # hw/xwin/winprocarg.c to put the GIT SHA1 in the Release string.
    git log -n 1 --oneline |\
	sed 's/^\([^ ]*\) .*/#define XSERVER_GIT_SHA1 "\1"/' \
	> hw/xwin/git_sha1.h.tmp
    if ! cmp -s hw/xwin/git_sha1.h.tmp hw/xwin/git_sha1.h; then
    	mv hw/xwin/git_sha1.h.tmp hw/xwin/git_sha1.h
    fi
fi
