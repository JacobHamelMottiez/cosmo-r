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


#' Save network data to CSV
#'
#' @param data List with nodes and edges
#' @param dir Output directory
#' @export
save_network_data <- function(data, dir) {
  write_csv(data$nodes, file.path(dir, "nodes.csv"))
  write_csv(data$edges, file.path(dir, "edges.csv"))
}







