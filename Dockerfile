FROM --platform=$BUILDPLATFORM golang:alpine AS build_deps

ARG TARGETPLATFORM
ARG BUILDPLATFORM

ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache git

WORKDIR /workspace
ENV GO111MODULE=on

COPY go.mod .
COPY go.sum .

RUN go mod download

FROM build_deps AS build

COPY . .

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o webhook -ldflags '-w -extldflags "-static"' .

FROM --platform=$BUILDPLATFORM alpine:3.9

ARG TARGETPLATFORM
ARG BUILDPLATFORM

RUN apk add --no-cache ca-certificates

COPY --from=build /workspace/webhook /usr/local/bin/webhook

ENTRYPOINT ["webhook"]
