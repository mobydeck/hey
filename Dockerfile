FROM golang:1.24.1-alpine as build

ARG build_flags

RUN apk update && apk add ca-certificates

WORKDIR /build

COPY . .

RUN CGO_ENABLED=0 go build "${build_flags}"

FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /build/hey /hey

ENTRYPOINT ["/hey"]
