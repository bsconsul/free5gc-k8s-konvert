DOCKER_IMAGE_OWNER = 'free5gc'
DOCKER_IMAGE_NAME = 'base'
DOCKER_IMAGE_TAG = 'latest'
DOCKER_NF_IMAGE_OWNER = 'bsconsul'
# we dont want to use latest until we fix the hard coded config - make it clear this is hardCfg
DOCKER_NF_IMAGE_TAG = 'hardCfg'

.PHONY: base
base:
	docker build -t ${DOCKER_IMAGE_OWNER}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ./base
	docker image ls ${DOCKER_IMAGE_OWNER}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}

.PHONY: net
net:
	for nf in amf ausf n3iwf nrf pcf smf udm udr upf upf2 upfb; do \
		docker build -t ${DOCKER_NF_IMAGE_OWNER}/${DOCKER_IMAGE_OWNER}-$$nf:${DOCKER_NF_IMAGE_TAG} ./nf_$$nf ; \
	done
	docker build -t ${DOCKER_NF_IMAGE_OWNER}/${DOCKER_IMAGE_OWNER}-webui:${DOCKER_NF_IMAGE_TAG} ./webui
#	for nf in amf  ; do \
#		docker build -t ${DOCKER_NF_IMAGE_OWNER}/${DOCKER_IMAGE_OWNER}-$$nf:${DOCKER_NF_IMAGE_TAG} ./nf_$$nf \
#    done	
