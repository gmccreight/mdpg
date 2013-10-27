#!/bin/bash

# style tests
./devtools/over_78_chars.sh
./devtools/trailing_whitespace.sh
./devtools/tabs.sh

perf=1 rake
karma start --single-run
