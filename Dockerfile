FROM qixxit/elixir-centos

MAINTAINER Ettore Berardi <ettore.berardi@bbc.co.uk>

LABEL uk.co.bbci.api.mozart="true"

#ADD dev.pem /opt/app/dev.pem
#ADD ca.pem /opt/app/ca.pem

ENV MIX_ENV=prod
ENV PORT=8080
ENV DEV_CERT_PEM=dev.pem

WORKDIR /opt/app

COPY . .

RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get && \
    mix release


# RUN APP_NAME="fetcher" && \
#     RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
#     mkdir /export && \
#     tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

EXPOSE 8080

ENTRYPOINT ["/opt/app/_build/prod/rel/fetcher/bin/fetcher"]
CMD ["foreground"]
