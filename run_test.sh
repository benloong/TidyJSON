#!/usr/bin/env bash
set -e

swift build --fetch
rm -rf ./Packages/*/Tests
swift build
swift test

exit 0
