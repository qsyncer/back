.PHONY: init sync update.package update.package.all update.package.all update.hooks

# Use a standard bash shell, avoid zsh or fish
SHELL:=/bin/bash

# variables
version?=$(shell python3 -c "from qsyncer import qsyncer; print(qsyncer.__version__)")


# update env vars
export PATH := ./venv/bin:$(PATH)

sync: venv qsyncer/requirements/base.txt qsyncer/requirements/dev.txt
	@pip-sync qsyncer/requirements/base.txt qsyncer/requirements/dev.txt

init: sync
	@pre-commit install  # installs pre-commit hooks
	@pre-commit install --hook-type commit-msg  # installs commit-msg hooks

venv:
	@python -m venv venv
	@pip install --quiet --upgrade pip
	@pip install --quiet pip-tools

qsyncer/requirements/base.txt: venv qsyncer/requirements/base.in
	@pip-compile --quiet --generate-hashes --max-rounds=20 \
		--output-file qsyncer/requirements/base.txt \
		qsyncer/requirements/base.in

qsyncer/requirements/dev.txt: venv qsyncer/requirements/base.txt qsyncer/requirements/dev.in
	@pip-compile --quiet --generate-hashes --max-rounds=20 \
		--output-file qsyncer/requirements/dev.txt \
		qsyncer/requirements/dev.in

update.package:
	@pip-compile \
		--upgrade-package=$(package) \
		--output-file qsyncer/requirements/$(type).txt \
		qsyncer/requirements/$(type).in

update.package.all:
	@$(MAKE) update.package.file file=base
	@$(MAKE) update.package.file file=dev

update.package.file:
	@pip-compile \
		--upgrade \
		--output-file qsyncer/requirements/$(file).txt \
		qsyncer/requirements/$(file).in

update.hooks:
	@pre-commit autoupdate

docker.build.app:
	docker build \
		--file docker/app/Dockerfile \
		--tag qsyncer_app:$(version) \
		--tag qsyncer_app:latest \
		qsyncer

docker.build.web:
	docker build \
		--tag qsyncer_web:$(version) \
		--tag qsyncer_web:latest \
		docker/web

django:
	PYTHONUNBUFFERED=1 \
	DJANGO_SETTINGS_MODULE=qsyncer.settings \
	DEBUG=True \
	CONFIGURATION_FILE=local/dev.yml \
	python qsyncer/manage.py $(args)
