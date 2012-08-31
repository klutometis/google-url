#!/usr/bin/env bash
# Usage: google-url [GOOGLE-URL]
# Extract URL from Google-URL or stdin.
#
# Google URLs look something like
# <http://www.google.com/url?sa=t&rct=j&q=foo&source=web&cd=1&ved=0CDIQFjAA&url=http%3A%2F%2Fen.wikipedia.org%2Fwiki%2FFoobar&ei=gBj9TtDpAcXT8QPI_4GdAQ&usg=AFQjCNH1J2pXAETcCKA7T6svhOKIRNyojg>,
# when what you want is <http://en.wikipedia.org/wiki/Foobar>; this
# trivial script extracts the latter from the former.
#
# Requires tidy (<http://tidy.sourceforge.net/>) and XMLStarlet
# (<http://xmlstar.sourceforge.net/>).

function curl-or-cat() {
    [ "$#" -eq 1 ] && curl -s "$1" || cat
}

function to-xml() {
    tidy -asxml -numeric -q --show-warnings no | xml fo
}

function find-redirect() {
    NAMESPACE="http://www.w3.org/1999/xhtml"

    xml sel -N x=$NAMESPACE -t \
        -m "//x:meta[@http-equiv='refresh']" \
        -v "@content"
}

function extract-url() {
    sed -nr "s/[0-9]+;URL='(.*)'/\1/p"
}

curl-or-cat "$@" | to-xml | find-redirect | extract-url
