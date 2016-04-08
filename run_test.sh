#!/usr/bin/env bash
set -e

SB=`which swift-build`
ST="swift test"
$SB --fetch
rm -rf ./Packages/*/Tests
$SB
$ST
exit 0
