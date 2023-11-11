#!/bin/bash

display_usage() {

echo "usage:
Set needed variables, then source this script and call upload
eg.
ENV=deploy
NAME=teamio-mpadmin-common
A_PATH=/teamio/services/mpadmin/nomad/jobs
OWNER=Teamio_RED
TEMPLATE_NAME=mpadmin.hcl

source configStoreUploaderBase.sh

upload

"
}


#check that all parameters are set to a value (not null)
checkParams(){
for param in "$@"
do
   :
   if [ -z "${param//}" ]; then
   echo "Not enough params were given to call the function!"
   echo $@
   exit 1
   fi
done
}

#check that the requested program is installed
check_program() {

if ! [ -x "$(command -v $1)" ]; then
  echo "Error: $1 is not installed." >&2
  exit 1
fi
}



#perform the upload
upload() {
check_program jq
check_program curl

set -x

checkParams "$ENV" "$NAME" "$A_PATH" "$OWNER" "$TEMPLATE_NAME"
if [ ! -r "$TEMPLATE_NAME" ]; then
    echo "Template '$TEMPLATE_NAME' not found!" >&2
    exit 2
fi
echo "Creating configuration"
RES=`curl -X POST  --header "Content-Type: application/vnd.api+json" -s -d '{
  "data": {
    "type": "configs",
    "attributes": {
      "name": "'"${NAME}"'",
      "path": "'"${A_PATH}"'",
      "owner": "'"${OWNER}"'"
    }
  }
}' http://config-store.${ENV}.services.lmc/v1/configs`

echo -e "Response:\n${RES}"

CONFIG_ID=`echo ${RES} | jq -r '.data.id'`
CONFIG_URL=`echo ${RES} | jq -r '.data.attributes.fileUrl'`
echo "Configuration ID: ${CONFIG_ID}"
echo "Configuration URL: ${CONFIG_URL}"

curl -X POST --data-binary "@${TEMPLATE_NAME}" http://config-store.${ENV}.services.lmc/v1/configs/${CONFIG_ID}/file
echo "Uploaded configuration data"
echo -e "Use the following URL template in Narwhal artifact:\n  $(tput setaf 2)${CONFIG_URL}$(tput sgr 0)"
}



#show usage when run directly (not sourced)
if [ "$0" = "$BASH_SOURCE" ] ; then
    display_usage
fi
