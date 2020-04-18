shared_local_config_path=`dirname $0`/_shared_local_config.sh

if [ -f $shared_local_config_path ]; then
  source $shared_local_config_path
  has_local_config=1
else
  echo please create a file at $shared_local_config_path with variables like:
  echo shared_mdpg_server=mdpg.co
  echo shared_mdpg_remote_path=\"~/mdpg\"
fi
