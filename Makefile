# Use a standard bash shell, avoid zsh or fish
SHELL:=/bin/bash

.PHONY: init sync update.package update.package.all update.package.all update.hooks

enable_venv=source venv/bin/activate

.ONESHELL:
	# all targets now use same sell for every lines

sync: venv qsyncer/requirements/base.txt qsyncer/requirements/dev.txt
	@source venv/bin/activate
	@pip-sync qsyncer/requirements/base.txt qsyncer/requirements/dev.txt

init: sync
	@source venv/bin/activate
	@pre-commit install  # installs pre-commit hooks
	@pre-commit install --hook-type commit-msg  # installs commit-msg hooks

venv:
	@python -m venv venv
	@source venv/bin/activate
	@pip install --quiet --upgrade pip
	@pip install --quiet pip-tools

qsyncer/requirements/base.txt: venv qsyncer/requirements/base.in
	@source venv/bin/activate
	pip-compile --quiet --generate-hashes --max-rounds=20 \
		--output-file qsyncer/requirements/base.txt \
		qsyncer/requirements/base.in

qsyncer/requirements/dev.txt: venv qsyncer/requirements/base.txt qsyncer/requirements/dev.in
	@source venv/bin/activate
	@pip-compile --quiet --generate-hashes --max-rounds=20 \
		--output-file qsyncer/requirements/dev.txt \
		qsyncer/requirements/dev.in

update.package:
	@source venv/bin/activate
	@pip-compile \
		--upgrade-package=$(package) \
		--output-file qsyncer/requirements/$(type).txt \
		qsyncer/requirements/$(type).in

update.package.all:
	@$(MAKE) update.package.file file=base
	@$(MAKE) update.package.file file=dev

update.package.file:
	@source venv/bin/activate
	@pip-compile \
		--upgrade \
		--output-file qsyncer/requirements/$(file).txt \
		qsyncer/requirements/$(file).in

update.hooks:
	@source venv/bin/activate
	@pre-commit autoupdate

version?=$(shell python3 -c "from qsyncer import qsyncer; print(qsyncer.__version__)")
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
