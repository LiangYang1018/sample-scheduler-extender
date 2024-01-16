# Build the manager binary
FROM golang:1.18 as builder
ARG TARGETOS
ARG TARGETARCH
ENV GOPROXY "https://goproxy.cn,direct"
ENV GOPROVATE "gitlab.ctyuncdn.cn,git.fogcdn.top"
WORKDIR /workspace

# Copy the Go Modules manifests
COPY . .
RUN go mod download
# Build
# the GOARCH has not a default value to allow the binary be built according to the host where the command
# was called. For example, if we call make docker-build in a local env which has the Apple Silicon M1 SO
# the docker BUILDPLATFORM arg will be linux/arm64 when for Apple x86 it will be linux/amd64. Therefore,
# by leaving it empty we can ensure that the container and binary shipped on it will have the same platform.
# RUN CGO_ENABLED=0 GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH} go build -a -o manager main.go
RUN CGO_ENABLED=0 GOOS=linux GO111MODULE=on go build -a -o my-app

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
# FROM gcr.io/distroless/static:nonroot
FROM alpine:3.13.6


RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories && \
    apk add --no-cache tcpdump lsof net-tools tzdata curl bash

ENV TZ Asia/Shanghai

WORKDIR /
COPY --from=builder /workspace/my-app .
USER 65532:65532

ENTRYPOINT ["/my-app"]
