#!/bin/bash

./devtools/over_78_chars.sh
perf=1 rake
karma start --single-run
