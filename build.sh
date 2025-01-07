#!/bin/bash

if [ ! -d "dist" ]; then
  mkdir dist
fi

swiftc -Onone ./src/code1.swift -o dist/code1
swiftc -O ./src/code1.swift -o dist/code1_opt

swiftc -Onone ./src/code2.swift -o dist/code2
swiftc -O ./src/code2.swift -o dist/code2_opt
