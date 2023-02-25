This repository contains the replication files for  

> Skinner, B.T., Levy, H., and Burtch, T. (2021). Digital redlining:
  the relevance of 20th century housing policy to 21st century
  broadband access and education. _Annenberg Institute at Brown
  University_ (EdWorkingPaper: 21-471). Doi:
  [10.26300/q9av-9c93](https://doi.org/10.26300/q9av-9c93)


## To run

Clone the project repository, `cd` into project directory, and run the `makefile`:

```bash
git clone https://github.com/btskinner/bb_holc_rep.git
cd ./bb_holc_rep
make
```

Or, after cloning the repository, `cd` into the `./scripts/r`
directory, and run the R scripts one by one in the following order:

1. `check_packages.R`
1. `make_data_acs.R`
1. `make_data_fcc.R`
1. `make_data_geo.R`
1. `clean_data_acs.R`
1. `clean_data_fcc.R`
1. `analysis_acs.R`
1. `analysis_fcc.R`
1. `make_figures.R`

Figures and tables found in the final paper can be built from
`figtab.md` after completing all scripts and running from the `docs`
directory:

``` sh
pandoc figures.md \
--read=markdown \
--write=latex \
--output=./figures.pdf \
--resource-path=..:../figures 
```
