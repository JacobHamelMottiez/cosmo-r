# cosmo-r

This project his to make it easier to transform Scopus data into Cosmograph data that you can use in ![cosmograph.app](https://cosmograph.app/run/). 

This package leverage the power of pybliometrics python package. You first need to download Scopus data from pybliometrics to use this cosmo-r package. For the curious, here is the documentation of pybliometrics ![Pybliometrics](pybliometrics.readthedocs.io). 

Here are the functions we use to retrieve citing and cited documents



To get articles information : 
``` python
result_list = []  # Initialize an empty list to store results

  
# Assuming result.chunk is an iterable (e.g., a list of queries or DOIs)

for query_item in result.chunk:
    pybliometrics.scopus.init()
    query = f"{query_item}"  # Use f-string for cleaner code
    print(query)

    s = ScopusSearch(query, verbose=True, subscriber=True, view="COMPLETE")
    df = pd.DataFrame(s.results)  # Add the results of each query to result_list
    result_list.append(df)  # Append each df to result_list

final_df = pd.concat(result_list, ignore_index=True)
final_df.to_csv("YOUR_PATH")

```


To get references informations : 
``` python 
def fetch_references(eid):
    try:
        ref_query = AbstractRetrieval(eid, id_type="eid", view="REF")
        if ref_query.references:
            return [{"id": ref.id, "source_eid": eid, "cited_year": ref.coverDate, "cited_journal" : ref.sourcetitle} for ref in ref_query.references]

    except Exception as e:
        print(f"Error processing EID {eid}: {e}")
    return []
```

Hence, the following function enable us to add the eid of the citing document the its the list of the documents its cited documents : 

You might wonder what is the difference between unique identifier eid for articles and id for references. 
- Eid : **2-s 2.0-84929582121**
- Id : ~~2-s 2.0-~~**84929582121**

Hence, for standardisation, we will remove the `2-s 2.0-` of EID from citing documents to get comparable unique identifiers. 

We now have all the relevant information to do network analysis. 
For now, this package focus on two classic methods in bibliometrics : bibliographic coupling and cocitation coupling. 

Many informations will be needed for visualisation in Cosmograph.app : 
- Node information : 
	- Node Cluster Id ; 
	- Node Cluster Color ; 
	- Node Weight ; 
- Edge information : 
	- From ;  
	- To ; 
	- Edge weight ; 
	- Edge Color ; 

Here is the code that enable us to get two .csv files that needed, one for nodes information, the other for edges information : 

Here is an example of how to use the plugin. Below, you will find the functions used for this particular example : 
```r
dir <- "YOUR_DIR"
arts <- read_csv(paste0(dir, "ARTICLES_SPECIAL_PHILO_BIO.csv"))
refs <- read_csv(paste0(dir, "REFERENCES_SPECIAL_PHILO_BIO.csv"))

x <- cosmo::build_cocitation_network(refs_spec_philo_bio)
z <- cosmo::extract_network_louvain(g = x, refs = refs, arts = arts, palette_func = scico,  palette_option = "hawaii")
cosmo::save_network_data(z,dir)
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

### Cluster louvain
```r
#' Generate node and edge data with Louvain community detection
#'
#' @param g An igraph object
#' @param refs Original reference data to merge back citation details
#' @return A list with node and edge data including Louvain communities and colors
#' @export
extract_network_louvain <- function(g, refs, palette_func = viridis::viridis, palette_option = NULL, scale_weight = 3) {
  library(dplyr)

  E(g)$weight <- E(g)$weight^scale_weight
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
