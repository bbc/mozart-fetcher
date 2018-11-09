.PHONY: build compile run

build:
	docker build -t fetcher .

compile:
	docker run \
		--rm=true \
		-v $(CURDIR):/opt/app \
		-w /opt/app \
		-e "DEV_CERT_PEM=$(DEV_CERT_PEM)" \
		-e "APP_NAME=fetcher" \
		-e "APP_VERSION=0.1.0" \
		-e "MIX_ENV=prod" \
		-e "RELEASE_DIR=_build/prod/rel/fetcher/releases/0.1.0/" \
		-p 8080:8080 \
		fetcher sh -c 'rm -rf _build tars && mkdir -p tars && mix release && cp _build/prod/rel/fetcher/releases/0.1.0/fetcher.tar.gz /opt/app/tars/'

run:
	docker run \
		--rm=true \
		-v $(CURDIR):/opt/app \
		-v $(DEV_CERT_PEM):$(DEV_CERT_PEM) \
		-w /opt/app \
		-e "DEV_CERT_PEM=$(DEV_CERT_PEM)" \
		-e "APP_NAME=fetcher" \
		-e "APP_VERSION=0.1.0" \
		-p 8080:8080 \
		fetcher sh -c 'mix run --no-halt'
