# ==============================================================================
# 
# [ PROJ ] Digital redlining: the relevance of 20th century housing policy to
#          21st century broadband access and education
# [ FILE ] makefile
# [ AUTH ] Benjamin Skinner (@btskinner), Hazel Levy, & Taylor Burtch
# [ INIT ] 18 January 2023
#
# ==============================================================================

# --- directories --------------------------------

DAT_DIR := data
DOC_DIR := docs
FIG_DIR := figures
SCR_DIR := scripts
TAB_DIR := tables

# --- variables ----------------------------------

# data vars
analysis_data := $(DAT_DIR)/clean/

# output vars (one example: assumes one change is all change)
pred_output := $(DAT_DIR)/
post_output := $(DAT_DIR)/
fig_output := $(FIG_DIR)/
tab_output := $(TAB_DIR)/
doc_figtab_output := figtab.pdf

# --- build targets ------------------------------

all: setup data analysis figures tables docs 

data: $(analysis_data)
analysis: $(pred_output)
figures: $(fig_output)
tables: $(tab_output)
docs: $(doc_figtab_output)

.PHONY: all setup data analysis figures tables docs

# --- packages -----------------------------------

setup:
	@echo "Checking for and installing necessary R packages"
	Rscript $(SCR_DIR)/r/check_packages.R .

# --- clean data ---------------------------------

$(analysis_data): $(SCR_DIR)/r/make_data.R $(ipums)
	@echo "Making analysis data"
	Rscript $< .

# --- analysis -----------------------------------

$(pred_output): $(SCR_DIR)/r/run_stan.R $(analysis_data) 
	@echo "Running Bayesian models"
	Rscript $< .

$(post_output): $(SCR_DIR)/r/poststratify.R $(pred_output) 
	@echo "Poststratifying predicted posteriors"
	Rscript $< .

# --- tables & figures ---------------------------

$(fig_output): $(SCR_DIR)/r/make_figures.R $(post_output)
	@echo "Making figures"
	Rscript $< .

$(tab_output): $(SCR_DIR)/r/make_tables.R $(post_output)
	@echo "Making tables"	
	Rscript $< .

# --- tab_fig ------------------------------------

$(doc_figtab_output): $(fig_output) $(tab_output)
	@echo "Compiling figures and tables document"
	cd docs && pandoc $(@:.pdf=.md) \
		--read=markdown \
		--write=latex \
		--output=$@ \
		--filter=pandoc-crossref \
		--lua-filter=linebreaks.lua \
		--resource-path=..:figures

# ------------------------------------------------------------------------------
# end makefile
# ==============================================================================
