#!/bin/sh
if [ -z "$KC_BOOTSTRAP_ADMIN_PASSWORD" ]; then
	echo "KC_BOOTSTRAP_ADMIN_PASSWORD is not set"
	exit 1
fi

if [ ! -d "$USER/keycloak/data" ]; then
	echo "creating $USER/keycloak"
	mkdir -p $USER/keycloak/logs
	mkdir -p $USER/keycloak/data
fi

docker run --rm \
	--name keycloak-ssi \
	-p 127.0.0.1:8080:8080 \
	-e KC_HOSTNAME=keycloak.labmtl.ca \
	-e KC_PROXY=edge \
	-e KC_BOOTSTRAP_ADMIN_USERNAME=admin \
	-e KC_BOOTSTRAP_ADMIN_PASSWORD=$KC_BOOTSTRAP_ADMIN_PASSWORD \
	-v /srv/keycloak/data:$USER/keycloak/data \
	-v /srv/keycloak/logs:$USER/keycloak/logs \
	quay.io/keycloak/keycloak:latest \
	start-dev --hostname keycloak.labmtl.ca --proxy-headers xforwarded \
		  --features=oid4vc-vci,oid4vc-vci-rest-credential-offer,oid4vc-vci-preauth-code
