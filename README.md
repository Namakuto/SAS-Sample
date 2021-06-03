## Multivariate Log-binomial (and Poisson) Regression between Years since Quitting Smoking and Self-reported Oral Health 
### A Sample of Work in SAS  
---
This folder contains a .pdf copy of my analysis of a subset of Candian Community Health Survey (CCHS) data from 2015-2016. The analysis is based on an assignment I did in graduate school, but I went back to fix a couple things and reduce some of my code.

The .pdf report shows the initial data cleaning/processes I did--or I would do--just before removing confounders from a full model.

I did not show a table of univariate statistics. I also did not show the process of actually removing any of the confounders from the full model (if confounding was present), as the focus of this document was to showcase my SAS coding abilities as well as some of my and modeling knowledge/capabilities. I did state what I would do to remove confounders (i.e., use the '+-20% change in the regression coefficient of interest' rule; alternatively, Greenland et al.'s (2006) method).

Note that my outcome variable (>2 categories) was transformed into a binary one, hence the use of a binomial model.
