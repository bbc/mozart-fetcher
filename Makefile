.PHONY: dependencies
COMPONENTNAME = mozart-fetcher
REGION = eu-west-1
BUILDPATH = /root/rpmbuild

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
	for component in ${COMPONENTS}; do \
		cosmos set-repositories $$component ${CODEPATH}/../infrastructure/stacks/repoconfig.json; \
		status_code="`curl -s -w "%{http_code}" -H "content-type:application/json" -X PUT --data @${CODEPATH}/../infrastructure/stacks/repo_modules.json --cert $$COSMOS_CERT --key $$COSMOS_CERT_KEY https://cosmos.api.bbci.co.uk/v1/services/$$component/repository_modules`"; \
		[[ "$$status_code" -eq 204 ]] || exit 1; \
	done; \

release:
	for component in ${COMPONENTS}; do \
		cosmos-release service $$component --release-version=v ${BUILDPATH}/RPMS/x86_64/*.x86_64.rpm; \
	done; \
