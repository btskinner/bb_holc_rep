# Documents

After running all analyses and creating all tables and figures, the
Markdown document, `figures.md`, can be compiled using pandoc to create
a PDF file of all paper figures. 

``` shell
cd ./docs
pandoc figures.md --read=markdown write=latex output=./figures.pdf resource-path=..:../figures 
```

