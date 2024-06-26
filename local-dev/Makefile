GREEN=\033[0;32m
BOLD=\033[1m
NC=\033[0m # No Color


py-here:
	@echo "$(BOLD)$(GREEN) Configurando Python $(VERSION) en este directorio$(NC)"
	pyenv local $(VERSION)
	cd $(PWD) && poetry env use python$(VERSION)
	@echo "$(BOLD)$(GREEN) Todo ok ✨ ✨ ✨"

