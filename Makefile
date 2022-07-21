PACKAGE_NAME := unstructured_api_tools
PIP_VERSION := 22.2.1


.PHONY: help
help: Makefile
	@sed -n 's/^\(## \)\([a-zA-Z]\)/\2/p' $<


###########
# Install #
###########

## install:                 installs all base, test, and dev requirements
.PHONY: install
install: install-base install-dev install-test

.PHONY: install-ci
install-ci: install-base install-test

.PHONY: install-base
install-base:
	python3 -m pip install pip==${PIP_VERSION}
	pip install -r requirements/base.txt

.PHONY: install-test
install-test:
	pip install -r requirements/test.txt

.PHONY: install-dev
install-dev:
	pip install -r requirements/dev.txt

## pip-compile:             compiles all base/dev/test requirements
.PHONY: pip-compile
pip-compile:
	pip-compile -o requirements/base.txt
	pip-compile requirements/dev.in
	pip-compile requirements/test.in

## install-project-local:   install unstructured_api_tools into your local python environment
.PHONY: install-project-local
install-project-local: install
	# MAYBE TODO: fail if already exists?
	pip install -e .

## uninstall-project-local: uninstall unstructured_api_tools from your local python environment
.PHONY: uninstall-project-local
uninstall-project-local:
	pip uninstall ${PACKAGE_NAME}

#################
# Test and Lint #
#################

## test:                    runs all unittests
.PHONY: test
test:
	PYTHONPATH=. pytest test_${PACKAGE_NAME} --cov=${PACKAGE_NAME} --cov-report term-missing -vvv

## check:                   runs linters (includes tests)
.PHONY: check
check: check-src check-tests

## check-src:               runs linters (source only, no tests)
.PHONY: check-src
check-src:
	black --line-length 100 ${PACKAGE_NAME} --check
	flake8 ${PACKAGE_NAME}
	mypy ${PACKAGE_NAME} --ignore-missing-imports --install-types --non-interactive

.PHONY: check-tests
check-tests:
	black --line-length 100 test_${PACKAGE_NAME} --check
	flake8 test_${PACKAGE_NAME}

## tidy:                    run black
.PHONY: tidy
tidy:
	black --line-length 100 ${PACKAGE_NAME}
	black --line-length 100 test_${PACKAGE_NAME}

.PHONY: check-coverage
check-coverage:
	coverage report --fail-under=95
