.PHONY: lint test build release install_cosmos_deploy
BUILDPATH = /root/rpmbuild

none:
	@ echo Please specifiy a target

dependencies:
	mix deps.get

test:
	MIX_ENV=test mix test

build:
	mix distillery.release
	mkdir -p ${BUILDPATH}/SOURCES
	cp _build/prod/rel/mozart_fetcher/releases/*/mozart_fetcher.tar.gz ${BUILDPATH}/SOURCES/
	tar -zcf ${BUILDPATH}/SOURCES/bake-scripts.tar.gz bake-scripts/
	cp mozart-fetcher.spec ${BUILDPATH}/SOURCES/
	cp SOURCES/* ${BUILDPATH}/SOURCES/
	rpmbuild --define "_topdir ${BUILDPATH}" --define "version ${COSMOS_VERSION}" --define '%dist .bbc.el8' -ba mozart-fetcher.spec

set_repositories:
	for component in ${COMPONENTS}; do \
		cosmos set-repositories $$component repositories.json; \
	done; \

release:
	for component in ${COMPONENTS}; do \
		cosmos-release service $$component --release-version=v ${BUILDPATH}/RPMS/x86_64/*.x86_64.rpm; \
	done; \

deploy:
	for component in ${COMPONENTS}; do \
		cosmos deploy $$component test --force --release ${COSMOS_VERSION}; \
	done; \