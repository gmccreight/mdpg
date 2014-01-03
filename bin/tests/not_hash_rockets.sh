#!/bin/bash

grep -r "[\"'a-z]:\s*[\"'a-z]" lib spec app.rb | grep -v "tags:"
