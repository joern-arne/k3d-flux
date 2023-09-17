FROM --platform=$BUILDPLATFORM golang:1.14-alpine AS build
ARG TARGETOS TARGETARCH

# Setup
RUN mkdir -p /go/src/github.com/mesosphere/traefik-forward-auth
WORKDIR /go/src/github.com/mesosphere/traefik-forward-auth

# Copy & build
ADD . /go/src/github.com/mesosphere/traefik-forward-auth/
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GO111MODULE=on go build -a -installsuffix nocgo -o /traefik-forward-auth github.com/mesosphere/traefik-forward-auth/cmd

COPY letsencrypt-stg-*.pem /usr/local/share/ca-certificates/

RUN cat /usr/local/share/ca-certificates/letsencrypt-stg-*.pem >> /etc/ssl/certs/ca-certificates.crt && \
    update-ca-certificates

# Copy into scratch container
FROM scratch
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /traefik-forward-auth ./
ENTRYPOINT ["./traefik-forward-auth"]
