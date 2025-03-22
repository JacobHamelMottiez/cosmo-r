# Hello, world!
#
# This is an example function named 'hello'
# which prints 'Hello, world!'.
#
# You can learn more about package authoring with RStudio at:
#
#   https://r-pkgs.org
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'



#' Load bibliographic data
#'
#' @param dir Path to the data directory
#' @return A list with articles and references data
#' @export
load_data <- function(dir) {
  library(readr)
  list(
    articles = read_csv(file.path(dir, "ARTICLES_SPECIAL_PHILO_BIO.csv")),
    references = read_csv(file.path(dir, "REFERENCES_SPECIAL_PHILO_BIO.csv"))
  )
}

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

#' Generate node and edge data with Louvain community detection
#'
#' @param g An igraph object
#' @param refs Original reference data to merge back citation details
#' @return A list with node and edge data including Louvain communities and colors
#' @export
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



#' Change node and edge colors
#'
#' @param node_data Data frame of nodes
#' @param edge_data Data frame of edges
#' @param palette_func Function to generate a color palette (e.g., viridis::viridis, scico::scico, RColorBrewer::brewer.pal)
#' @param palette_option Palette option for the chosen function (if applicable)
#' @return A list with updated node and edge colors
#' @export
change_network_colors <- function(node_data, edge_data, palette_func = scico::scico, palette_option = "hawaii") {
  library(dplyr)

  unique_communities <- unique(node_data$community)
  palette <- palette_func(n = length(unique_communities), palette = palette_option)
  community_colors <- setNames(palette, unique_communities)

  node_data <- node_data |> mutate(node_color = community_colors[as.character(community)])
  edge_data <- edge_data |> mutate(edge_color = community_colors[as.character(from)])

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







