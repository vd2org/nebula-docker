FROM debian:12 as builder

ARG VERSION

RUN apt-get update && apt-get install -y curl

RUN case $(uname -m) in \
    x86_64) \
        echo linux-amd64 > /platform ;; \
    aarch64) \
        echo linux-arm64 > /platform ;; \
    *) \
        echo "Unknown architecture: $(uname -m)" \
        exit 1 ;; \
    esac

WORKDIR /opt

RUN echo Building $(cat /platform) image for ${VERSION}...

RUN curl -L "https://github.com/slackhq/nebula/releases/download/${VERSION}/nebula-$(cat /platform).tar.gz" | tar -xz


FROM debian:12

RUN mkdir -p /opt/nebula/config /opt/nebula/certs /opt/nebula/ssh

COPY --from=builder /opt/nebula /opt/nebula/
COPY --from=builder /opt/nebula-cert /opt/nebula/

VOLUME /opt/nebula/config
VOLUME /opt/nebula/certs
VOLUME /opt/nebula/ssh

WORKDIR /opt/nebula

CMD ["/opt/nebula/nebula", "-config", "/opt/nebula/config/nebula.yaml"]
