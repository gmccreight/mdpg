#!/bin/bash

rubocop | egrep --color=always "[0-9]+ offenses detected"
