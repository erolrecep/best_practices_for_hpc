# ==============================================================================
# Makefile: Best Practices for Using HPC Presentation & Workshop
# ==============================================================================
# Commands to serve, inspect, and export the Reveal.js presentation.
# ==============================================================================

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Default target displays the interactive command menu
.DEFAULT_GOAL := help
.PHONY: default help slides serve export-pdf check clean

# Server configuration
PORT ?= 8000

# Color formatting
CYAN  := \033[36m
GREEN := \033[32m
BOLD  := \033[1m
RESET := \033[0m

default: help

help: ## Display this command reference menu
	@echo ""
	@echo -e "$(CYAN)======================================================================$(RESET)"
	@echo -e "$(BOLD)   Best Practices for Using HPC: Workshop Presentation Console$(RESET)"
	@echo -e "$(CYAN)======================================================================$(RESET)"
	@echo -e "Usage: $(BOLD)make [command]$(RESET) [PORT=8000]"
	@echo ""
	@echo -e "$(BOLD)Available Commands:$(RESET)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-16s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo -e "$(CYAN)======================================================================$(RESET)"
	@echo ""

slides: ## Serve the Reveal.js presentation at http://localhost:PORT and open in browser
	@echo -e "$(GREEN)🚀 Launching presentation at http://localhost:$(PORT)...$(RESET)"
	@echo -e "💡 Press $(BOLD)Ctrl+C$(RESET) to stop the server."
	@if command -v open >/dev/null 2>&1; then \
		(sleep 1 && open "http://localhost:$(PORT)/index.html") & \
	elif command -v xdg-open >/dev/null 2>&1; then \
		(sleep 1 && xdg-open "http://localhost:$(PORT)/index.html") & \
	fi; \
	python3 -m http.server $(PORT)

serve: slides ## Alias for 'slides'

check: ## Verify that presentation assets, images, and SLURM scripts exist
	@echo -e "$(CYAN)--- Verifying Workshop Assets ---$(RESET)"
	@test -f index.html && echo -e "  $(GREEN)[✓] index.html (Reveal.js slides)$(RESET)" || (echo "  [✗] index.html missing"; exit 1)
	@test -f images/avatar.jpeg && echo -e "  $(GREEN)[✓] images/avatar.jpeg (Profile portrait)$(RESET)" || (echo "  [✗] avatar.jpeg missing"; exit 1)
	@test -f about_me.html && echo -e "  $(GREEN)[✓] about_me.html (Modular bio snippet)$(RESET)" || (echo "  [✗] about_me.html missing"; exit 1)
	@echo -e "$(CYAN)--- Verifying SLURM Comparison Scripts ---$(RESET)"
	@for f in SLURM_scripts/*.sh; do \
		test -f "$$f" && echo -e "  $(GREEN)[✓] $$f$(RESET)"; \
	done
	@echo -e "$(GREEN)✅ All assets verified successfully.$(RESET)"

export-pdf: ## Guide on how to export presentation to PDF format
	@echo ""
	@echo -e "$(CYAN)======================================================================$(RESET)"
	@echo -e "$(BOLD)          Exporting Reveal.js Presentation to PDF$(RESET)"
	@echo -e "$(CYAN)======================================================================$(RESET)"
	@echo -e "1. Run $(BOLD)make slides$(RESET) to start the local server."
	@echo -e "2. In Google Chrome or Chromium, navigate to:"
	@echo -e "   $(CYAN)http://localhost:$(PORT)/index.html?print-pdf$(RESET)"
	@echo -e "3. Open the Print dialog ($(BOLD)Cmd+P$(RESET) on Mac or $(BOLD)Ctrl+P$(RESET) on Linux)."
	@echo -e "4. Set Destination to $(BOLD)Save as PDF$(RESET)."
	@echo -e "5. Under More Settings:"
	@echo -e "   - Layout: $(BOLD)Landscape$(RESET)"
	@echo -e "   - Margins: $(BOLD)None$(RESET)"
	@echo -e "   - Check: $(BOLD)Background graphics$(RESET)"
	@echo -e "6. Click Save."
	@echo -e "$(CYAN)======================================================================$(RESET)"
	@echo ""

clean: ## Remove temporary build files
	@find . -type f -name "*~" -delete
	@echo -e "$(GREEN)✅ Clean completed.$(RESET)"
