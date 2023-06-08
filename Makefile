include .env

.DEFAULT_GOAL := help

.PHONY: help
help: ## Displays help for all make commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## install required tools to build
	brew install dbmate buildpacks/tap/pack
	pip3 install --upgrade pip
	pip3 install "poetry==${POETRY_VERSION}"

## Code formatting/linting

.PHONY: black
black: ## Formats code
	@poetry run black .

.PHONY: ruff
ruff: ## Lints code
	@poetry run ruff check .

.PHONY: ruff
ruff-fix: ## Lints code
	@poetry run ruff --fix .

.PHONY: format
format: black ruff-fix mypy ## Formats and checks code with mypy

.PHONY: mypy
mypy: ## Checks static types
	@poetry run mypy .

.PHONY: toml-sort
toml-sort: ## Formats pyproject.toml
	@poetry run toml-sort pyproject.toml -i -a

.PHONY: lint
lint: ruff mypy ## Validates formatting and static typing

.PHONY: build
build: format lint toml-sort ## Builds project

## Run via poetry

.PHONY: run-dev
run-dev: ## Runs the local dev server via poetry
	@poetry run uvicorn basic_api.main:app --reload --host 127.0.0.1

## build docker container using buildpacks
.PHONY: build-docker
build-docker:
	export DOCKER_BUILDKIT=0
	export COMPOSE_DOCKER_CLI_BUILD=0
	export DOCKER_DEFAULT_PLATFORM=linux/amd64
	pack build basic-api --builder paketobuildpacks/builder:base --buildpack paketo-buildpacks/python  --env 'BP_CPYTHON_VERSION PYTHON_VERSION=$(PYTHON_VERSION)' --env 'BP_POETRY_VERSION=$(POETRY_VERSION)'

.PHONY: docker-run
docker-run: ## Runs the service via docker in the foreground
	docker run -p $(PORT):$(PORT) $(DOCKER_IMG)
