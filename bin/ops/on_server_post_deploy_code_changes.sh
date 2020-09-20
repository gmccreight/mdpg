#!/bin/bash

# This code runs on the server

app_dir=`dirname $0`/../../

(
  cd $app_dir

  deploy_timestamp=`date +'%s'`

  # Update the CSS with a timestamp to break the cache on deploy
  mv public/style.css public/style_$deploy_timestamp.css
  cat views/layout.haml | sed -e "s/style.css/style_$deploy_timestamp.css/" > views/layout_updated.haml
  mv views/layout_updated.haml views/layout.haml
)
