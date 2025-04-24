.PHONY: dependencies test
COMPONENT_NAME = mozart-fetcher
COMPONENT = mozart-fetcher-eu-west-1
REGION = eu-west-1
BUILD_PATH = /root/rpmbuild

none:
	@ echo Please specify a target

dependencies:
	mix deps.get

test:
	MIX_ENV=test mix compile
	MIX_ENV=test mix test

build:
	$(eval COSMOS_VERSION:=$(shell cosmos-release generate-version ${COMPONENT_NAME}-${REGION}))
	mix deps.get
	mix release
	mkdir -p ${BUILD_PATH}/SOURCES
	cp _build/prod/mozart_fetcher-1.0.0.tar.gz ${BUILD_PATH}/SOURCES/mozart_fetcher.tar.gz
	tar -zcf ${BUILD_PATH}/SOURCES/bake-scripts.tar.gz bake-scripts/
	cp mozart-fetcher.spec ${BUILD_PATH}/SOURCES/
	cp SOURCES/* ${BUILD_PATH}/SOURCES/
	rpmbuild --define "_topdir ${BUILD_PATH}" --define "version ${COSMOS_VERSION}" --define '%dist .bbc.el9' -ba mozart-fetcher.spec

release:
	cosmos set-repositories ${COMPONENT} repositories.json; \
	cosmos-release service ${COMPONENT} --release-version=v ${BUILDPATH}/RPMS/x86_64/*.x86_64.rpm;
