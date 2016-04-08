#!/bin/bash
set -e

swift build --fetch
rm -rf Packages/*/Tests
swift build
swift test
