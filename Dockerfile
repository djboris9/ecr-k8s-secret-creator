FROM golang:1.12-alpine as builder
RUN apk --no-cache add git

ENV GO111MODULE=on
ENV CGO_ENABLED=0

WORKDIR /vgo/
COPY . .

RUN go get ./...
RUN go test ./...
RUN go build -o /bin/ecr-k8s-secret-creator .

# Build runtime
FROM alpine:latest as runtime

RUN apk --no-cache add ca-certificates
COPY --from=builder /bin/ecr-k8s-secret-creator /bin/ecr-k8s-secret-creator

# Run as nobody:x:65534:65534:nobody:/:/sbin/nologin
USER 65534

ENTRYPOINT ["/bin/ecr-k8s-secret-creator"]
