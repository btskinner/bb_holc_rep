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
analysis_acs_data := $(DAT_DIR)/clean/holc_acs_analysis.RDS
analysis_fcc_data := $(DAT_DIR)/clean/holc_fcc_analysis.RDS

# output vars (one example: assumes one change is all change)
acs_output := $(DAT_DIR)/clean/predictions_acs.RDS
fcc_output := $(DAT_DIR)/clean/predictions_fcc.RDS
fig_output := $(FIG_DIR)/inc_cbb_line.pdf
tab_output := $(TAB_DIR)/desc.tex
doc_output := $(DOC_DIR)/figtab.pdf

# --- build targets ------------------------------

all: setup data analysis figures tables docs 

data: $(analysis_data)
analysis: $(est_output) $(prd_output)
figures: $(fig_output)
tables: $(tab_output)
docs: $(doc_output)

.PHONY: all setup data analysis figures tables docs

# --- packages -----------------------------------

setup:
	@echo "Checking for and installing necessary R packages"
	Rscript $(SCR_DIR)/r/check_packages.R .

# --- make data ----------------------------------

$(analysis_acs_data): $(SCR_DIR)/r/make_data_acs.R
	@echo "Making ACS analysis data"
	Rscript $< .

$(analysis_fcc_data): $(SCR_DIR)/r/make_data_fcc.R
	@echo "Making FCC analysis data"
	Rscript $< .

# --- analysis -----------------------------------

$(acs_output): $(SCR_DIR)/r/analysis_acs.R $(analysis_acs_data) 
	@echo "Running Bayesian models for ACS data"
	Rscript $< .

$(fcc_output): $(SCR_DIR)/r/analysis_fcc.R $(analysis_fcc_data) 
	@echo "Running Bayesian models for FCC data"
	Rscript $< .

# --- tables & figures ---------------------------

$(fig_output): $(SCR_DIR)/r/make_figures.R $(acs_output) $(fcc_output)
	@echo "Making figures"
	Rscript $< .

$(tab_output): $(SCR_DIR)/r/make_tables.R $(acs_output) $(fcc_output)
	@echo "Making tables"	
	Rscript $< .

# --- tab_fig ------------------------------------

# $(doc_figtab_output): $(fig_output) $(tab_output)
# 	@echo "Compiling figures and tables document"
# 	cd docs && pandoc $(@:.pdf=.md) \
# 		--read=markdown \
# 		--write=latex \
# 		--output=$@ \
# 		--filter=pandoc-crossref \
# 		--lua-filter=linebreaks.lua \
# 		--resource-path=..:figures

# ------------------------------------------------------------------------------
# end makefile
# ==============================================================================
