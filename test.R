library(igraph)
library(dplyr)
library(tidyverse)
library(tidygraph)
library(data.table)
library(scico)



dir <- "C:/Users/jacob/OneDrive - Université Laval/biophilo/Data/pybiblio/SPECIALIZED PHILOSOPHY OF BIOLOGY/"
spec_philo_bio <- read_csv(paste0(dir, "ARTICLES_SPECIAL_PHILO_BIO.csv"))
refs_spec_philo_bio <- read_csv(paste0(dir, "REFERENCES_SPECIAL_PHILO_BIO.csv"))



philo_bio <- refs_spec_philo_bio |> select(citing_id, cited_id) |> distinct()
refs_spec_philo_bio <- refs_spec_philo_bio |> group_by(cited_id) |> add_count(cited_id) |> filter(n>5) |> select(citing_id, cited_id) |> ungroup()  |> distinct()
refs = refs_spec_philo_bio

# Step 1: Create an initial graph (undirected, as we are interested in bibliographic coupling)
graph <- graph_from_data_frame(refs, directed = FALSE)

# Step 2: Calculate shared references (bibliographic coupling)
# We will count how many times two papers share references in the 'refs' data


# Step 3: Build a graph from the shared references with weights
bibc_graph <- bibcoupling(graph, ) |> graph_from_adjacency_matrix(mode = "undirected")

library(tidygraph)




x <- cosmo::build_bibcoupling_network(refs_spec_philo_bio)
z <- cosmo::extract_network_data_test(g = x, refs = refs_spec_philo_bio, arts = spec_philo_bio, palette_func = scico,  palette_option = "hawaii")

#z$nodes <- z$nodes |> filter(info != "NA, NA, NA")


cosmo::save_network_data(z,dir)




z$nodes |> distinct(node_color)



library(tidyverse)
library(igraph)

# Sample data: citing_id (citing paper), cited_id (referenced paper)
df <- tibble(
  citing_id = c("A", "A", "B", "B", "C", "C", "D"),
  cited_id = c("X", "Y", "X", "Z", "Y", "Z", "X")
)

# Compute bibliographic coupling (shared references count)
bib_coupling_matrix <- refs_spec_philo_bio %>%
  inner_join(refs_spec_philo_bio, by = "cited_id") %>%
  filter(citing_id.x != citing_id.y) %>%
  count(citing_id.x, citing_id.y, name = "weight")

# Create a bibliographic coupling network
bib_coupling_graph <- graph_from_data_frame(bib_coupling_matrix, directed = FALSE)

# Compute Louvain clustering
clustering <- cluster_louvain(bib_coupling_graph)
V(bib_coupling_graph)$cluster <- membership(clustering)

# Plot network with clusters
plot(
  bib_coupling_graph,
  vertex.color = V(bib_coupling_graph)$cluster,
  edge.width = E(bib_coupling_graph)$weight,
  vertex.size = 10,
  main = "Bibliographic Coupling Network"
)

library(devtools)
use_github()
