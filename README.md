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

Or, after cloning the repository, run the R scripts one by one:



Figures and tables found in the final paper can be built from
`figtab.md` after completing all scripts and running from the `docs`
directory:

``` sh
pandoc figtab.md \
--read=markdown \
--write=latex \
--output=./figtab.pdf \
--filter=pandoc-crossref \
--citeproc \
--lua-filter=linebreaks.lua
```
