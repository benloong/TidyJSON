#!/bin/bash
swift build -k
swift build

swiftc Tests/Test.swift Tests/main.swift -o .build/debug/test -I .build/debug/ -L .build/debug/ -Xlinker .build/debug/TidyJSON.a
.build/debug/test