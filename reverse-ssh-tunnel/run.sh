#!/usr/bin/with-contenv bashio

bashio::log.info "Reverse tunnel initializing."

key_file=/private.key

bashio::log.info "Variables set, reading configuration."

username=$(bashio::config 'username')
host=$(bashio::config 'server.host')
port=$(bashio::config 'server.port')

bashio::log.info "Reverse tunnel configured for $username@$host"

if bashio::config.exists 'private_key'; then

  bashio::log.info "Using private key authorization"

  echo $(bashio::config 'private_key')
  print $(bashio::config 'private_key')
  printf "%b" "$(bashio::config 'private_key')"

  echo $(bashio::config 'private_key') | sed 's/\\n$/\n/g' > $key_file
  cat $key_file
  chmod 600 $key_file

  bashio::log.info "Initializing the ssh tunnel"
  ssh -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o PubkeyAuthentication=yes \
    -o PasswordAuthentication=no \
    -i $key_file \
    -R 9090:homeassistant.local:8123 \
    $username@$host

elif bashio::config.exists 'password'; then
  bashio::log.info "Using password authorization"

  password=`bashio::config 'password'`

  bashio::log.info "Initializing the ssh tunnel"
  
  sshpass -p $password ssh -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -R 9090:homeassistant.local:8123 \
    $username@$host

else 
  bashio::log.error "Neither private key nor password provided. Exiting!"
fi 
