# Final Project

This repository contains code and the written manuscript discussing Covid-19 data and how Covid-19 rates vary in rural and urban counties. The manuscript also discusses how masks have impacted covid rates as well as current predictions for the effective reproductive number and future predictions with the new introduction of the Omicron variant. 

This repository contains the following folders:

Data: this folder is used to hold raw data and output data.
R: this folder holds all R code.
Figs: holds figures generated from R code.
Doc: holds the manuscript.

Some prerequisites:

GNU Make: to document file dependencies and automate workflow. In terminal, you can just type make to render the rmarkdown file to pdf and html.
R: for data clean and analyses.
LaTeX: for fine control of typesetting and pdf generation. Recommend to use tinytex.
Pandoc: for file types converting, e.g. convert markdown file to pdf or docx files or html files.
if you have Rstudio installed, you can also use pandoc shipped with Rstudio