name = Tneller Script

NO_COLOR=\033[0m		# Color Reset
COLOR_OFF='\e[0m'       # Color Off
OK_COLOR=\033[32;01m	# Green Ok
ERROR_COLOR=\033[31;01m	# Error red
WARN_COLOR=\033[33;01m	# Warning yellow
RED='\e[1;31m'          # Red
GREEN='\e[1;32m'        # Green
YELLOW='\e[1;33m'       # Yellow
BLUE='\e[1;34m'         # Blue
PURPLE='\e[1;35m'       # Purple
CYAN='\e[1;36m'         # Cyan
WHITE='\e[1;37m'        # White

all:
	@printf "$(OK_COLOR)==== Create ${name}... ====$(NO_COLOR)\n"
	@bash scripts/tuneller.sh

help:
	@echo -e "$(OK_COLOR)==== All commands of ${name} configuration ====$(NO_COLOR)"
	@echo -e "$(WARN_COLOR)- make env			: Create .env file"
	@echo -e "$(WARN_COLOR)- make				: Create script"
	@echo -e "$(WARN_COLOR)- make service			: Create systemd service for script"
	@echo -e "$(WARN_COLOR)- make push			: Push changes to repository"
	@echo -e "$(WARN_COLOR)- make pull			: Pull from repository"
	@echo -e "$(WARN_COLOR)- make clean			: Remove script$(NO_COLOR)"

env:
	@printf "$(OK_COLOR)==== Create environment file for ${name}... ====$(NO_COLOR)\n"
	@if [ -f .env ]; then \
		rm .env; \
	fi; \
	cp .env.example .env

push:
	@printf "$(OK_COLOR)==== Push last changes to repo... ====$(NO_COLOR)\n"
	@bash scripts/push.sh

pull:
	@printf "$(OK_COLOR)==== Pull last changes from repo... ====$(NO_COLOR)\n"
	@bash scripts/pull.sh

git:
	@bash scripts/gituser.sh

service:
	@printf "$(OK_COLOR)==== Create ${name} Service... ====$(NO_COLOR)\n"
	@bash scripts/create_service.sh

clean:
	@printf "$(OK_COLOR)==== Remove ${name} Script... ====$(NO_COLOR)\n"
	@bash scripts/remover.sh

.PHONY  : all help env push pull git service clean
