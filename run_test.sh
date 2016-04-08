#!/usr/bin/env bash
set -e

SB=`which swift-build`
ST="swift test"
ls -la .

$SB --fetch

ls -la .

rm -rf ./Packages/*/Tests

ls -la ./Packages

$SB
$ST
exit 0
