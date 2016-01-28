#!/usr/bin/env bash

set -e
xcodebuild -project TidyJSON.xcodeproj -list
xcodebuild -project TidyJSON.xcodeproj -scheme "TidyJSON-iOS" -destination "platform=iOS Simulator,name=iPhone 6" test

xcodebuild -project TidyJSON.xcodeproj -scheme "TidyJSON-OSX" test

xcodebuild -project TidyJSON.xcodeproj -scheme "TidyJSON-tvOS" -destination "platform=tvOS Simulator,name=Apple TV 1080p" test
