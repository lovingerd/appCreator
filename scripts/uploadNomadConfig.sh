#!/bin/bash
ENV=deploy
NAME=teamio-springboot-template
A_PATH=/teamio/services/springboot/template
OWNER=recruit
TEMPLATE_NAME=template.nomad

git archive --remote=ssh://git@bitbucket.lmc.cz:7999/tech/scripts.git master jenkins2/configStoreUploaderBase.sh | tar -xO > configStoreUploaderBase.sh
source ./configStoreUploaderBase.sh

upload
