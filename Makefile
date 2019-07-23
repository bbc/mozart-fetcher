.PHONY: build compile run

build:
	docker build -t mozart_fetcher .

compile:
	docker run \
		--rm=true \
		-v $(CURDIR):/opt/app \
		-w /opt/app \
		-e "DEV_CERT_PEM=$(DEV_CERT_PEM)" \
		-e "APP_NAME=mozart_fetcher" \
		-e "APP_VERSION=0.1.0" \
		-e "RELEASE_DIR=_build/prod/rel/mozart_fetcher/releases/0.1.0/" \
		-p 8080:8080 \
		mozart_fetcher sh -c 'rm -rf _build tars && mkdir -p tars && mix release && cp _build/prod/rel/mozart_fetcher/releases/0.1.0/mozart_fetcher.tar.gz /opt/app/tars/'

run:
	docker run \
		--rm=true \
		-v $(CURDIR):/opt/app \
		-v $(DEV_CERT_PEM):$(DEV_CERT_PEM) \
		-w /opt/app \
		-e "DEV_CERT_PEM=$(DEV_CERT_PEM)" \
		-e "APP_NAME=mozart_fetcher" \
		-e "APP_VERSION=0.1.0" \
		-p 8080:8080 \
		mozart_fetcher sh -c 'mix run --no-halt'
