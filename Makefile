.PHONY: all fetch clean fetch_google_api fetch_google_protobuf fetch_swagger install_protoc protoc_go docs

all: clean fetch install_protoc protoc_go

WD := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))

fetch: fetch_google_protobuf fetch_google_api fetch_swagger

clean:
	rm -rf ${WD}/google

fetch_google_api:
	-mkdir -p ${WD}/google/api

	curl -L https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/annotations.proto -o ${WD}/google/api/annotations.proto
	curl -L https://raw.githubusercontent.com/googleapis/googleapis/master/google/api/http.proto -o ${WD}/google/api/http.proto

fetch_google_protobuf:
	-mkdir -p ${WD}/google/protobuf

	curl -L https://raw.githubusercontent.com/protocolbuffers/protobuf/master/src/google/protobuf/descriptor.proto -o ${WD}/google/protobuf/descriptor.proto
	curl -L https://raw.githubusercontent.com/protocolbuffers/protobuf/master/src/google/protobuf/any.proto -o ${WD}/google/protobuf/any.proto
	curl -L https://raw.githubusercontent.com/protocolbuffers/protobuf/master/src/google/protobuf/struct.proto -o ${WD}/google/protobuf/struct.proto

fetch_swagger:
	-mkdir -p ${WD}/protoc-gen-openapiv2/options

	curl -L https://raw.githubusercontent.com/grpc-ecosystem/grpc-gateway/master/protoc-gen-openapiv2/options/annotations.proto -o ${WD}/protoc-gen-openapiv2/options/annotations.proto
	curl -L https://raw.githubusercontent.com/grpc-ecosystem/grpc-gateway/master/protoc-gen-openapiv2/options/openapiv2.proto -o ${WD}/protoc-gen-openapiv2/options/openapiv2.proto

install_protoc:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.11
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.6.0
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway@v2.27.7
	go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@v2.27.7
	npm install @redocly/cli@2.14.0

protoc_go: ${GOPATH}/bin/protoc-gen-go
	protoc --proto_path=$(WD) \
		   --go_out=${WD} \
		   --go_opt=paths=source_relative \
		   --go-grpc_out=${WD} \
		   --go-grpc_opt=paths=source_relative \
		   --grpc-gateway_out=logtostderr=true:${WD} \
		   --grpc-gateway_opt=paths=source_relative \
		   --openapiv2_out=logtostderr=true,json_names_for_fields=false:${WD} \
		   $(WD)/dynizer.proto

	protoc --proto_path=$(WD) \
		   --openapiv2_out=logtostderr=true,json_names_for_fields=false,output_format=yaml:${WD} \
		   $(WD)/dynizer.proto

	go run $(WD)/custom/main.go --dir=${WD} --spec-custom=$(WD)/custom/spec_custom.yaml
	npx @redocly/cli bundle ${WD}/dynizer.swagger.yaml -o ${WD}/dynizer.swagger.json

docs:
	mkdir -p ${WD}/docs
	npx @redocly/cli build-docs ${WD}/dynizer.swagger.json -o ${WD}/docs/index.html
