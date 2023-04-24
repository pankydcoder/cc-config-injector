FROM golang:1.19.2-alpine AS build
ENV GO111MODULE on
ENV CGO_ENABLED 0

RUN apk add git make openssl

WORKDIR /go/src/github.com/confluentinc/cc-config-injector
ADD . .
RUN make test
RUN make app

FROM scratch
WORKDIR /app
COPY --from=build /go/src/github.com/confluentinc/cc-config-injector/mutateme .
COPY --from=build /go/src/github.com/confluentinc/cc-config-injector/ssl ssl
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
CMD ["/app/mutateme"]