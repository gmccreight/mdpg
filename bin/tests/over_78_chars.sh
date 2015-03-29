#!/bin/bash

find . -name "*app_data*" -prune -o -print | \
egrep "\.(coffee|css|haml|md|rb|sh)" | xargs egrep "^.{79}"
