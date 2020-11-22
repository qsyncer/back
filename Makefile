# Use a standard bash shell, avoid zsh or fish
SHELL:=/bin/bash

.PHONY: init sync update.package update.package.all update.package.all update.hooks

enable_venv=source venv/bin/activate

.ONESHELL:
	# all targets now use same sell for every lines

sync: venv requirements/base.txt requirements/dev.txt
	@source venv/bin/activate
	@pip-sync requirements/base.txt requirements/dev.txt

init: sync
	@source venv/bin/activate
	@pre-commit install  # installs pre-commit hooks
	@pre-commit install --hook-type commit-msg  # installs commit-msg hooks

venv:
	@python -m venv venv
	@source venv/bin/activate
	@pip install --quiet --upgrade pip
	@pip install --quiet pip-tools

requirements/base.txt: venv requirements/base.in
	@source venv/bin/activate
	pip-compile --quiet --generate-hashes --max-rounds=20 \
		--output-file requirements/base.txt \
		requirements/base.in

requirements/dev.txt: venv requirements/base.txt requirements/dev.in
	@source venv/bin/activate
	@pip-compile --quiet --generate-hashes --max-rounds=20 \
		--output-file requirements/dev.txt \
		requirements/dev.in

update.package:
	@source venv/bin/activate
	@pip-compile \
		--upgrade-package=$(package) \
		--output-file requirements/$(type).txt \
		requirements/$(type).in

update.package.all:
	@$(MAKE) update.package.file file=base
	@$(MAKE) update.package.file file=dev

update.package.file:
	@source venv/bin/activate
	@pip-compile \
		--upgrade \
		--output-file requirements/$(file).txt \
		requirements/$(file).in

update.hooks:
	@source venv/bin/activate
	@pre-commit autoupdate
