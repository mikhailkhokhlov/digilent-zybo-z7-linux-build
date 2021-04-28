#!/bin/sh

DTC_REPO=https://git.kernel.org/pub/scm/utils/dtc/dtc.git

build_dtc() {
  if [ -d "dtc" ]; then
    echo "=== DTC already exists."
    echo ""
  else
    echo "=== Getting DTC sources..."
    echo ""

    git clone ${DTC_REPO}

    echo "=== Build DTC..."
    echo ""

    cd dtc
    make -j $(nproc --all) || return 1

    echo "=== Install dtc to ${LOCAL_BINARY}"
    cp -v dtc ${LOCAL_BINARY}

    cd -
  fi
}

