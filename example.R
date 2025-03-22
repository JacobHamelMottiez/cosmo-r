library(igraph)
library(dplyr)
library(tidyverse)
library(tidygraph)
library(data.table)
library(scico)

dir <- "C:/Users/jacob/OneDrive - Université Laval/biophilo/Data/pybiblio/SPECIALIZED PHILOSOPHY OF BIOLOGY/"
spec_philo_bio <- read_csv(paste0(dir, "ARTICLES_SPECIAL_PHILO_BIO.csv"))
refs_spec_philo_bio <- read_csv(paste0(dir, "REFERENCES_SPECIAL_PHILO_BIO.csv"))


refs_spec_philo_bio <- refs_spec_philo_bio |> group_by(cited_id) |> add_count(cited_id) |> filter(n>5) |> select(citing_id, cited_id) |> ungroup()  |> distinct()

# Build the network and extract the data
x <- cosmo::build_bibcoupling_network(refs_spec_philo_bio)
z <- cosmo::extract_network_data(g = x, refs = refs_spec_philo_bio, arts = spec_philo_bio, palette_func = scico,  palette_option = "hawaii")

# Save the results
cosmo::save_network_data(z,dir)


