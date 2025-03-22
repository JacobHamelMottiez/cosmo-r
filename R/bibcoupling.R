# Load required libraries
library(igraph)
library(dplyr)
library(tidyverse)
library(tidygraph)
library(data.table)
library(scico)


#' Find the most common value in a vector
#'
#' This function determines the most frequently occurring value.
#'
#' @param x A vector
#' @return The most common value in the vector
#' @export
most_common <- function(x) {
  if (all(is.na(x))) return(NA)  # Handle all NA cases
  x[which.max(tabulate(match(x, unique(x))))]  # Find most frequent value
}


#' Clean bibliographic references
#'
#' This function cleans and processes bibliographic reference data.
#' It standardizes the source title and extracts relevant fields.
#'
#' @param references A dataframe of references
#' @return A cleaned dataframe with formatted citations
#' @export
clean_references_fct <- function(references) {
  references$sourcetitle <- toupper(references$sourcetitle)
  references <- references %>%
    rename(cited_id = id, citing_id = citing_eid, cited_title = sourcetitle) %>%
    mutate(citing_id = str_extract(citing_id, "(?<=2-s2\\.0-)[0-9]+")) %>%
    rename(cited_year = publicationyear)

  references <- references %>%
    group_by(cited_id) %>%
    mutate(
      title = most_common(title),
      sourcetitle = most_common(authors),
      publicationyear = most_common(cited_year)
    ) %>%
    ungroup() %>%
    distinct()
  return(references)
}


#' Process bibliographic coupling data
#'
#' This function applies cleaning operations and filters out references
#' with low citation counts.
#'
#' @param refs A dataframe of bibliographic coupling data
#' @return A list containing cleaned and filtered data
#' @export
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



  # Step 5: Return the graph with edge weights
  return(bib_coupling_graph)
}

extract_network_data_test <- function(g, refs, arts, palette_func = viridis::viridis, palette_option = "A") {
  library(dplyr)
  library(igraph)

  #E(g)$weight <- E(g)$weight^3
  louvain <- cluster_louvain(g, resolution = 2)

  V(g)$community <- membership(louvain)
  V(g)$weight <- degree(g)

  # Generate color palette
  palette <- palette_func(n = length(unique(V(g)$community)), palette = palette_option)
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

  data <- arts |> rename(id = citing_id) |> select(id, citing_year, author_names, citing_title)


  node_data <- node_data |> left_join(data, by = "id")
  node_data <- node_data |> mutate(info = paste0(author_names, ", ", citing_year, ", ", citing_title)) |> distinct()

  list(nodes = node_data, edges = edge_data)
}



#' Save network data to CSV
#'
#' @param data List with nodes and edges
#' @param dir Output directory
#' @export
save_network_data <- function(data, dir) {
  write_csv(data$nodes, file.path(dir, "nodes.csv"))
  write_csv(data$edges, file.path(dir, "edges.csv"))
}

