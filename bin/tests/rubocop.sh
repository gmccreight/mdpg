#!/bin/bash

rubocop -l | egrep --color=always "[0-9]+ offenses detected"
