#!/usr/bin/bash
#
#   graphite.sh - Compile with polyhedral model optimization
#

[[ -n "$LIBMAKEPKG_BUILDENV_GRAPHITE_SH" ]] && return
LIBMAKEPKG_BUILDENV_GRAPHITE_SH=1

LIBRARY=${LIBRARY:-'/usr/share/makepkg'}

source "$LIBRARY/util/option.sh"

build_options+=('graphite')
buildenv_functions+=('buildenv_graphite')

buildenv_graphite() {
    if check_buildoption "graphite" "y"; then

        GRAPHITE="-fgraphite-identity -floop-interchange -floop-nest-optimize -floop-parallelize-all -ftree-loop-distribution -ftree-parallelize-loops=$(getconf _NPROCESSORS_ONLN) -ftree-vectorize -fopenmp"

        CFLAGS="${CFLAGS} $GRAPHITE"
        CXXFLAGS="${CXXFLAG} $GRAPHITE"
    fi
}
