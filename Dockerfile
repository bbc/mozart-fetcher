FROM qixxit/elixir-centos

MAINTAINER Ettore Berardi <ettore.berardi@bbc.co.uk>
MAINTAINER Sam French <Sam.French@bbc.co.uk>

LABEL uk.co.bbci.api.mozart="true"

ENV PORT=8080

WORKDIR /opt/app

ADD . /opt/app

RUN mix deps.get

EXPOSE 8080

CMD ["/bin/sh"]
