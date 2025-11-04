SHELL := /bin/bash
REPO_NAME := ai-algorithms

ifeq ($(OS),Windows_NT)
    PYTHON = python.exe
    ACTIVATE_VENV = venv\Scripts\activate
else
    PYTHON = python3.13
    ACTIVATE_VENV = source ./venv/bin/activate
endif
PIP = $(PYTHON) -m pip

ifneq ("$(wildcard .env)","")
    include .env
else
    $(shell echo -e "ENVIRONMENT=dev" >> .env)
endif

.PHONY: analyze pre-commit init lint clean test build release all python-init help

# Default target executed when no arguments are given to make.
all: help

# -------------------------------------------------------------------------
# Install and run pre-commit hooks
# -------------------------------------------------------------------------
pre-commit:
	pre-commit install
	pre-commit autoupdate
	pre-commit run --all-files

# ---------------------------------------------------------
# create a local python virtual environment. Includes linters
# and other tools for local development.
# ---------------------------------------------------------
python-init:
	make clean
	$(PYTHON) -m venv venv && \
	$(ACTIVATE_VENV) && \
	$(PIP) install --upgrade pip && \
	$(PIP) install -r requirements/local.txt && \
	deactivate

######################
# CORE COMMANDS
######################
init:
	make clean && \
	make python-init && \
	npm install && \
	$(ACTIVATE_VENV) && \
	$(PIP) install -U 'pip<25.3' && \
	$(PIP) install -r requirements/local.txt && \
	pre-commit install && \
	deactivate

test:
	$(ACTIVATE_VENV) && python -m unittest discover -s azure_ai/; \

test-ci:
	python -m unittest discover -s azure_ai/;

lint:
	isort . && \
	pre-commit run --all-files && \
	black . && \
	flake8 ./azure_ai/ && \
	pylint ./azure_ai/**/*.py

clean:
	rm -rf venv node_modules azure_ai/__pycache__ package-lock.json

analyze:
	cloc . --exclude-ext=svg,json,zip,csv,yml,yaml --vcs=git

release:
	git commit -m "fix: force a new release" --allow-empty && git push



######################
# HELP
######################

help:
	@echo '===================================================================='
	@echo 'analyze         - generate code analysis report'
	@echo 'release         - force a new GitHub release'
	@echo 'init            - create a Python virtual environment and install prod dependencies'
	@echo 'python-init     - create a Python virtual environment with local dependencies'
	@echo 'pre-commit      - install and run pre-commit hooks'
	@echo 'test            - run Python unit tests'
	@echo 'lint            - run Python linting'
	@echo 'clean           - destroy the Python virtual environment'
	@echo '===================================================================='
