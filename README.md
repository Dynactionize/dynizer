## Dynizer API definitions

This repository contains the Dynizer v2 public API definitions and generated artifacts. The
source of truth is `dynizer.proto`, which is used to generate:

- Go gRPC server/client stubs (`dynizer.pb.go`, `dynizer_grpc.pb.go`)
- gRPC-Gateway handlers (`dynizer.pb.gw.go`)
- OpenAPI/Swagger specs (`dynizer.swagger.yaml`, `dynizer.swagger.json`)
- Static API docs (`docs/index.html`)

The OpenAPI header in `dynizer.proto` describes the public API for the Dynizer knowledge
engine and is tagged for Redoc.

## Repository layout

- `dynizer.proto`: main protobuf + gRPC API definition
- `custom/spec_custom.yaml`: additional OpenAPI paths merged into the generated spec
- `custom/main.go`: merges `spec_custom.yaml` into `dynizer.swagger.yaml`
- `docs/index.html`: generated Redoc docs
- `google/` and `protoc-gen-openapiv2/`: vendored proto dependencies for swagger annotations

## Generate code and specs

This repo relies on `GOPATH` and expects to live under it (see the Makefile). Typical flow:

```sh
make clean
make fetch
make install_protoc
make protoc_go
```

That sequence fetches the proto dependencies, installs the required code generators, and
regenerates the Go/Swagger outputs from `dynizer.proto`.

## Generate docs

Redoc builds a single HTML file from the Swagger JSON:

```sh
make docs
```

The output is written to `docs/index.html`.

## Additional API specs

Besides the main Dynizer API, this repo ships three additional OpenAPI specs:

- `dynizer-analyze-api.openapi.yaml`: analysis endpoints
- `dynizer-mag-api.openai.yml`: MAG-related endpoints
- `dynizer-pipeline-api.openapi.yaml`: pipeline endpoints

## Requirements

- Go 1.24+
- `protoc`
- Node.js + npm (for `@redocly/cli`)

## Notes

- `make docs` uses `@redocly/cli build-docs` against `dynizer.swagger.json`.
- If you change the OpenAPI spec or custom paths, rerun `make protoc_go` before `make docs`.
