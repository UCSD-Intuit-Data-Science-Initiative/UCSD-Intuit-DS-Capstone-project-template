.PHONY: help install lint format test docs clean precommit

POETRY ?= poetry
.DEFAULT_GOAL := help


##@Setup
install: ## Install project and dev dependencies
	$(POETRY) install
	$(POETRY) run pre-commit install

##@Quality
lint: ## Run static analysis with Ruff and type checks with mypy
	$(POETRY) run ruff check src tests scripts
	$(POETRY) run mypy src tests

format: ## Format code using Ruff
	$(POETRY) run ruff check --fix src tests scripts
	$(POETRY) run ruff format src tests scripts
	$(MAKE) clean

test: ## Execute test suite via tox (py)
	$(POETRY) run tox -e py

##@Documentation
docs: ## Build documentation (placeholder)
	@echo "Docs target pending documentation tooling"

##@Pipelines
pipeline-run: ## Execute sample training pipeline
	$(POETRY) run python scripts/run_pipeline.py --demo

pipeline-help: ## Show pipeline CLI help
	$(POETRY) run python scripts/run_pipeline.py --help

##@Maintenance
clean: ## Remove caches and build artifacts
	@ $(MAKE) clean-pyc
	@ $(MAKE) clean-build
	@ $(MAKE) clean-test
	@ $(MAKE) clean-cache
	@ echo "✅ Cleaned up build artifacts and caches"

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +
	find . -name "__pycache__" -type d -prune -exec rm -rf {} +

clean-build:
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-test:
	rm -rf .tox
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache
	rm -fr .mypy_cache
	rm -rf coverage_*.xml
	rm -rf coverage.xml

clean-cache:
	rm -rf .mypy_cache .pytest_cache .ruff_cache dist build

precommit: ## Run all pre-commit hooks against the codebase
	$(POETRY) run pre-commit run --all-files


##@General
help: ## Show grouped make targets with descriptions
	@awk 'BEGIN { \
		FS = ":.*?##"; \
		header = "============================================"; \
		title_color = "\033[1;35m"; \
		section_color = "\033[1;34m"; \
		target_color = "\033[36m"; \
		desc_color = "\033[0;37m"; \
		muted_color = "\033[0;90m"; \
		reset = "\033[0m"; \
		print ""; \
		printf "%s%s%s\n", title_color, header, reset; \
		printf "%s   Project Command Reference   %s\n", title_color, reset; \
		printf "%s%s%s\n\n", title_color, header, reset; \
		printf "%sUse make <target> to run a task.%s\n\n", muted_color, reset; \
	} \
	/^##@/ { \
		section = substr($$0, 4); \
		printf "%s%s%s\n", section_color, section, reset; \
		next; \
	} \
	/^[a-zA-Z0-9_-]+:.*?##/ { \
		desc = $$2; \
		gsub(/^[[:space:]]+/, "", desc); \
		printf "  • %s%-18s%s %s%s%s\n", target_color, $$1, reset, desc_color, desc, reset; \
	} \
	END { \
		printf "\n%s%s%s\n\n", title_color, header, reset; \
	}' $(MAKEFILE_LIST)
