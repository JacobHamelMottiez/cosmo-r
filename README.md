# cosmo-r
![b9de9fa3-6e38-47f7-85c4-d45a87e3ce59](https://github.com/user-attachments/assets/7c66e0a4-887e-4fdc-a709-ee4a47166099)

## Package introduction
This project goal his to make it easier to transform Scopus data into ![Cosmograph.app visualisation](https://cosmograph.app/run/). 

_Cosmo-r_ package leverage the power of _Pybliometrics_ python package that help us interacting with various Scopus APIs. One way wonder why we use _Pybliometrics_ instead of _R-Scopus_. The main justification for it is easier to deal with bigger dataset with the former. However, if you work with R-Scopus, you will be able to use this package given that you use the same column title as we do. See `column_names` file to reformat your data so it is compatible with this plugin. 

You first need to download Scopus data from _Pybliometrics_. We included in the Pybliometrics_functions.ipynb notebook that contains the various functions we use to fetch citing and cited documents. For supplementary information, you can refer to Pybliometrics documentation ![Pybliometrics](pybliometrics.readthedocs.io). 

## Main functions of cosmo-r
For now, this package focus on two classic methods used in bibliometric analysis: bibliographic coupling and cocitation coupling. 
Our functions do the following : 
1. Create a graph based on citing and cited unique identifiers provided by Scopus (`build_cocitation_network(refs)`). 
3. Create clusters and add information for visualisation purpose in _Cosmograph.app_ (`extract_network_louvain(graph, refs, arts, palette_func, palette_option)`). Here is some of the info added : 
	- Node information : 
		- Node Cluster Id ; 
		- Node Cluster Color ; 
		- Node Weight.
	- Edge information : 
		- From ;  
		- To ; 
		- Edge weight ; 
		- Edge Color.
4. Save two .csv files needed for visualisation in _cosmograph.app_ (`save_network_data (graph, dir)`). 

Here is an example of how to use the plugin. Below, you will find the functions described through points 1-4 : 

### How to use the package? A simple example
```r
# PACKAGES
library(igraph)
library(dplyr)
library(tidyverse)
library(tidygraph)
library(data.table)
library(scico)

dir <- "YOUR_DIR"

# DATA (Example with personal data from philosophy of biology) 
arts <- read_csv(paste0(dir, "ARTICLES_SPECIAL_PHILO_BIO.csv"))
refs <- read_csv(paste0(dir, "REFERENCES_SPECIAL_PHILO_BIO.csv"))

# FUNCTIONS
x <- cosmo::build_cocitation_network(refs_spec_philo_bio)
z <- cosmo::extract_network_louvain(g = x, refs = refs, arts = arts, palette_func = scico,  palette_option = "hawaii")
cosmo::save_network_data(z,dir)
```

# What can you achieve with cosmograph.app visualisations? 
## _You can use it as a first step towards visualising communities_
![Screenshot 2024-10-31 145249](https://github.com/user-attachments/assets/2d68e066-5970-4571-81d3-fdf337ff0fd5)
## _You can isolate clusters_
![Screenshot 2025-02-25 204355](https://github.com/user-attachments/assets/776f6995-6833-40d5-83c0-77ecd2b1360e)
## _You can create and interact with a timeline_
![Screenshot 2025-03-10 141518](https://github.com/user-attachments/assets/b4953c99-ff42-4d66-ae9d-b611c82d54bf)
