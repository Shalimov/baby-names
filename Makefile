def_env_build_options = --rm -it -e DB_HOST=$(DBHOST) -e PORT=$(PORT) -e API_HOST=$(RHOST)
env_build_options = $(def_env_build_options)
build_img = build-babynames:latest

ifneq ($(findstring $(MAKECMDGOALS), upgrade),)
	env_build_options = $(def_env_build_options) -e UPGRADE=true
endif

help:
		@IFS=$$'\n' ; \
		help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
		printf "%-30s %s\n" "target" "help" ; \
		printf "%-30s %s\n" "------" "----" ; \
		for help_line in $${help_lines[@]}; do \
				IFS=$$':' ; \
				help_split=($$help_line) ; \
				help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
				help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
				printf '\033[36m'; \
				printf "%-30s %s" $$help_command ; \
				printf '\033[0m'; \
				printf "%s\n" $$help_info; \
		done

start: deliver ## Starts an app in foreground
	@bash $(PWD)/bin/remote-start.sh

upgrade: deliver ## Upgrades the running app
	@bash $(PWD)/bin/remote-upgrade.sh

deliver: build ## Delivers app artifacts to remote machine
	@bash $(PWD)/bin/delivery.sh

build: prepare_image ## Prepare app artifacts
	docker run -v $(PWD):/opt/build $(env_build_options) $(build_img) /opt/build/bin/build.sh

prepare_image: validate_params
	docker build -t=$(build_img) .

validate_params: 
	@bash $(PWD)/bin/validate_params.sh

test_container_run: ## Open container with all mappings for testing purposes
	docker run -v $(PWD):/opt/build $(env_build_options) $(build_img)