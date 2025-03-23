#' Find the most common value in a vector
#'
#' This function determines the most frequently occurring value.
#'
#' @param references A tibble with references
#' @return The most common value for each references that share the same unique identifier. 
#' @export
library(tidyverse)

clean_references_fct <- function(references) {
  references <- reformat_references(references)
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
