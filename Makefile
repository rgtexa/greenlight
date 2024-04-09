# Include environment variables from .envrc
include .envrc

#
# HELPERS
#

## help: prints this help message
.PHONY: help
help:
	@echo 'Usage: '
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

#
# DEVELOPMENT
#

## run/api: run the cmd/api application
.PHONY: run/api
run/api:
	@echo 'Running application...'
	@go run ./cmd/api -db-dsn=${GREENLIGHT_DSN}

## db/psql: connect to the database using the psql utility
.PHONY: db/psql
db/psql:
	psql ${GREENLIGHT_DSN}

## db/migrations/new name=$1: create a new set of sequential migrations with name
.PHONY: db/migrations/new
db/migrations/new:
	@echo 'Creating migration files for ${name}...'
	migrate create -seq -ext .sql -dir ./migrations ${name}

## db/migrations/up: apply all up database migrations
.PHONY: db/migrations/up
db/migrations/up: confirm
	@echo 'Running up migrations...'
	migrate -path ./migrations -database ${GREENLIGHT_DSN} up

#
# QUALITY CONTROL
#

## audit: tidy dependencies and format, vet, and test all code
.PHONY: audit
audit: vendor
	@echo 'Formatting code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	staticcheck ./...
	@echo 'Running tests...'
	go test -race --vet=off ./...

## vendor: tidy and vendor dependencies
.PHONY: vendor
vendor:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Vendoring dependencies...'
	go mod vendor

#
# BUILD
#

## build/api: build the cmd/api application
.PHONY: build/api
build/api:
	@echo 'Building cmd/api...'
	set GOOS=windows
	set GOARCH=amd64
	go build -ldflags='-s' -o=./bin/api.exe ./cmd/api
#	set GOOS=linux
#	set GOARCH=amd64
#	go build -ldflags='-s' -o=./bin/linux_amd64/api ./cmd/api