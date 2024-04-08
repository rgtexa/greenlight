# Include environment variables from .envrc
include .envrc

## help: prints this help message
.PHONY: help
help:
	@echo 'Usage: '
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

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