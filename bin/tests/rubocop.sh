#!/bin/bash

rm -f .rubocop_result
rubocop --out .rubocop_result

if egrep --quiet "[0-9]+ offenses detected" .rubocop_result; then
  cat .rubocop_result

  RED='\033[0;31m'
  NC='\033[0m' # No Color
  printf "${RED}rubocop discovered some offenses!${NC}\n"
fi
