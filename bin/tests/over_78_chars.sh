#!/bin/bash

find . -type f | egrep "\.(coffee|css|haml|md|rb)" | xargs egrep "^.{79}" \
  | grep -v "codeclimate.com/repos"