#!/bin/bash

./bin/tests/all_style.sh

perf=1 COVERALLS_RUN_LOCALLY=1 rake
karma start --single-run
