#!/bin/bash

if [ ! -d "dist" ]; then
  mkdir dist
fi

swiftc -Onone ./src/code0.swift -o dist/code0
swiftc -O ./src/code0.swift -o dist/code0_opt

swiftc -Onone ./src/code1.swift -o dist/code1
swiftc -O ./src/code1.swift -o dist/code1_opt

swiftc -Onone ./src/code2.swift -o dist/code2
swiftc -O ./src/code2.swift -o dist/code2_opt

swiftc -Onone ./src/code3.swift -o dist/code3
swiftc -O ./src/code3.swift -o dist/code3_opt

# 計測
swiftc -Onone ./src/measure/measure.swift  -o dist/measure
