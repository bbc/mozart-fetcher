.PHONY: dependencies
COMPONENTNAME = mozart-fetcher
REGION = eu-west-1
BUILDPATH = /root/rpmbuild
COMPONENTS = mozart-fetcher-eu-west-1 mozart-fetcher-weather-eu-west-1 mozart-fetcher-sport-eu-west-1

none:
	@ echo Please specifiy a target

dependencies:
	mix deps.get

test:
	MIX_ENV=test mix test

build:
	$(eval COSMOS_VERSION:=$(shell cosmos-release generate-version ${COMPONENTNAME}-${REGION}))
	mix distillery.release
	mkdir -p ${BUILDPATH}/SOURCES
	cp _build/prod/rel/mozart_fetcher/releases/*/mozart_fetcher.tar.gz ${BUILDPATH}/SOURCES/
	tar -zcf ${BUILDPATH}/SOURCES/bake-scripts.tar.gz bake-scripts/
	cp mozart-fetcher.spec ${BUILDPATH}/SOURCES/
	cp SOURCES/* ${BUILDPATH}/SOURCES/
	rpmbuild --define "_topdir ${BUILDPATH}" --define "version ${COSMOS_VERSION}" --define '%dist .bbc.el8' -ba mozart-fetcher.spec

set_repositories:
	git clone --single-branch --branch master https://github.com/bbc/mozart-fetcher-build
	for component in ${COMPONENTS}; do \
		export COSMOS_CERT=/etc/pki/tls/certs/client.crt; \
		export COSMOS_CERT_KEY=/etc/pki/tls/private/client.key; \
		cosmos set-repositories $$component mozart-fetcher-build/repositories.json; \
	done; \

release:
	echo "Releasing 'RPMS/**/*.rpm' to ${COMPONENTNAME}-${REGION}"
	for component in ${COMPONENTS}; do \
		cosmos-release service $$component --release-version=v ${BUILDPATH}/RPMS/x86_64/*.x86_64.rpm; \
	done; \
