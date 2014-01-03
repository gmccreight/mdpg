#!/bin/bash

# style tests
./bin/tests/not_hash_rockets.sh
./bin/tests/over_78_chars.sh
./bin/tests/trailing_whitespace.sh
./bin/tests/tabs.sh

perf=1 rake
karma start --single-run
