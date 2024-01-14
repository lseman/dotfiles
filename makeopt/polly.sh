#!/usr/bin/bash
#
#   graphite.sh - Compile with polyhedral model optimization
#

[[ -n "$LIBMAKEPKG_BUILDENV_POLLY_SH" ]] && return
LIBMAKEPKG_BUILDENV_POLLY_SH=1

LIBRARY=${LIBRARY:-'/usr/share/makepkg'}

source "$LIBRARY/util/option.sh"

build_options+=('polly')
buildenv_functions+=('buildenv_polly')

buildenv_polly() {
    if check_buildoption "polly" "y"; then

        POLLY="-mllvm -polly -mllvm -polly-parallel -mllvm -polly-num-threads=$(getconf _NPROCESSORS_ONLN) -lgomp"
        CFLAGS+=" $POLLY"
        CXXFLAGS+=" $POLLY"
    fi
}
