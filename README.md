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

### Bibliographic coupling 
---
```r
build_bibcoupling_network <- function(refs) {
  library(igraph)
  library(dplyr)

  refs <- refs |> select(citing_id, cited_id)

  # Step 1: Create an initial graph (undirected, as we are interested in bibliographic coupling)

  # Compute bibliographic coupling (shared references count)
  bib_coupling_matrix <- refs %>%
    inner_join(refs, by = "cited_id") %>%
    filter(citing_id.x != citing_id.y) %>%
    count(citing_id.x, citing_id.y, name = "weight")

  # Create a bibliographic coupling network
  bib_coupling_graph <- graph_from_data_frame(bib_coupling_matrix, directed = FALSE)
```

### Cocitation coupling 
---
```r
#' Build cocitation network
#'
#' @param refs Data frame of references
#' @return An igraph object representing the cocitation network
#' @export
build_cocitation_network <- function(refs) {
  library(igraph)

  refs <- refs |> dplyr::group_by(cited_id) |> dplyr::add_count(cited_id) |> dplyr::ungroup()
  refs <- refs |> dplyr::filter(n > 5) |> dplyr::distinct()

  incidence_matrix <- table(refs$citing_id, refs$cited_id)
  cocitation_matrix <- t(incidence_matrix) %*% incidence_matrix

  cocitation_df <- as.data.frame(as.table(cocitation_matrix))
  colnames(cocitation_df) <- c("cited_id_1", "cited_id_2", "weight")
  cocitation_df <- cocitation_df |> dplyr::filter(cited_id_1 != cited_id_2 & weight > 5)

  graph_from_data_frame(cocitation_df, directed = FALSE)
}
```
### Clustering and Network information 
---
```r
extract_network_data <- function(g, refs, palette_func = viridis::viridis, palette_option = "A") {
  library(dplyr)
  library(igraph)


  E(g)$weight <- E(g)$weight^3
  louvain <- cluster_louvain(g, resolution = 1)

  V(g)$community <- membership(louvain)
  V(g)$weight <- degree(g)

  # Generate color palette
  palette <- palette_func(n = length(unique(V(g)$community)), option = palette_option)
  community_colors <- palette[V(g)$community]

  node_data <- data.frame(
    id = V(g)$name,
    community = V(g)$community,
    node_weight = V(g)$weight,
    node_color = community_colors
  )

  edge_list <- as_edgelist(g)
  edge_data <- as_tibble(edge_list) |>
    rename(from = V1, to = V2) |>
    mutate(edge_weight = E(g)$weight,
           edge_color = community_colors[match(from, node_data$id)])

  # Get back some citation details
  data <- refs |> rename(id = cited_id) |> select(id, cited_title, authors, cited_year, sourcetitle)
  node_data <- node_data |> left_join(data, by = "id")
  node_data <- node_data |> mutate(info = paste0(authors, ", ", cited_year, ", ", cited_title, ", ", sourcetitle)) |> distinct()

  list(nodes = node_data, edges = edge_data)
}
```

### Save Network
---
```r
#' Save network data to CSV
#'
#' @param data List with nodes and edges
#' @param dir Output directory
#' @export
save_network_data <- function(data, dir) {
  write_csv(data$nodes, file.path(dir, "nodes.csv"))
  write_csv(data$edges, file.path(dir, "edges.csv"))
}
```
