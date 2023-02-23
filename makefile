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
init_acs_data := $(DAT_DIR)/clean/acs_2015_2019_seq_135_sumlvl_140_us.RDS
init_fcc_data := $(DAT_DIR)/clean/broadband_bg.RDS
init_geo_data := $(DAT_DIR)/clean/sf_tr_holc.RDS
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

acs_data_init: $(init_acs_data)
fcc_data_init: $(init_fcc_data)
acs_data_clean: $(analysis_acs_data)
fcc_data_clean: $(analysis_fcc_data)
geo_data: $(init_geo_data)
acs_data: acs_data_init acs_data_clean
fcc_data: fcc_data_init fcc_data_clean
data: acs_data fcc_data geo_data
acs_analysis: $(acs_output)
fcc_analysis: $(fcc_output)
analysis: acs_analysis fcc_analysis
figures: $(fig_output)
tables: $(tab_output)
docs: $(doc_output)

.PHONY: all setup data analysis figures tables docs

# --- packages -----------------------------------

setup:
	@echo "Checking for and installing necessary R packages"
	Rscript $(SCR_DIR)/r/check_packages.R .

# --- make data ----------------------------------

$(init_acs_data): $(SCR_DIR)/r/make_data_acs.R
	@echo "Initializing ACS analysis data"
	Rscript $< .

$(init_fcc_data): $(SCR_DIR)/r/make_data_fcc.R
	@echo "Initializing FCC analysis data"
	Rscript $< .

$(init_geo_data): $(SCR_DIR)/r/make_data_geo.R $(init_acs_data) $(init_fcc_data)
	@echo "Initializing geography analysis data"
	Rscript $< .

$(analysis_acs_data): $(SCR_DIR)/r/clean_data_acs.R $(init_acs_data) $(init_geo_data)
	@echo "Cleaning ACS analysis data"
	Rscript $< .

$(analysis_fcc_data): $(SCR_DIR)/r/clean_data_fcc.R $(int_fcc_data) $(init_geo_data)
	@echo "Cleaning FCC analysis data"
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
