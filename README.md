# cosmo-r
![b9de9fa3-6e38-47f7-85c4-d45a87e3ce59](https://github.com/user-attachments/assets/7c66e0a4-887e-4fdc-a709-ee4a47166099)

## Package introduction
This project goal his to make it easier to transform Scopus data into Cosmograph.app visualisation that you can use ![here](https://cosmograph.app/run/). 

_Cosmo-r_ package leverage the power of _Pybliometrics_ python package to fetch articles, references and more generally, all the metadata that we may need. We use _Pybliometrics_ instead of _R-Scopus_ for various reason, mainly the fact that it is easier to deal with bigger dataset with the former. However, if you work with R-Scopus, you will be able to use this package given that you use the same column title as we do. 

** Provide a file with the column names necessary for this plugin**

You first need to download Scopus data from _Pybliometrics_. We included in the Pybliometrics_documentation file the various functions we use to fetch articles and references with _Pybliometrics_ package. For supplementary information, you can refer to Pybliometrics documentation ![Pybliometrics](pybliometrics.readthedocs.io). 


## Main functions of cosmo-r
For now, this package focus on two classic methods used in bibliometric analysis: bibliographic coupling and cocitation coupling. 
Our functions do the following : 
1. Create a graph based on citing and cited unique identifiers provided by Scopus.
2. Create clusters based on nodes connections between each other (for now, we only provide support for Louvain algorithm. In the future, we plan to integrate Leiden and other well-known clustering algorithm).
3. Add informations for visualisation purpose in _Cosmograph.app_ such as : 
	- Node information : 
		- Node Cluster Id ; 
		- Node Cluster Color ; 
		- Node Weight.
	- Edge information : 
		- From ;  
		- To ; 
		- Edge weight ; 
		- Edge Color.
4. Create two .csv files needed for visualisation in _cosmograph.app_. 

Here is an example of how to use the plugin. Below, you will find the functions described through points 1-4 : 

### Example
---
```r
dir <- "YOUR_DIR"

# Example with personal data from philosophy of biology. 
arts <- read_csv(paste0(dir, "ARTICLES_SPECIAL_PHILO_BIO.csv"))
refs <- read_csv(paste0(dir, "REFERENCES_SPECIAL_PHILO_BIO.csv"))

x <- cosmo::build_cocitation_network(refs_spec_philo_bio)
z <- cosmo::extract_network_louvain(g = x, refs = refs, arts = arts, palette_func = scico,  palette_option = "hawaii")
cosmo::save_network_data(z,dir)
```
