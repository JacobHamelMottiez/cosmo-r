#' Clean bibliographic references
#'
#' This function cleans and processes bibliographic reference data.
#' It standardizes the source title and extracts relevant fields.
#'
#' @param articles A dataframe of articles
#'
#' @return A cleaned dataframe with formatted citations
#' @export
#'
library(tidyverse)

reformat_articles  <- function(articles) {
  articles <- rename(arts,
                     citing_id = eid,
                     citing_journal = publicationName,
                     citing_authors = authors_names,
                     citing_year = coverDate,
                     citing_title = title,
                     citing_doi = doi)
  articles <- articles |> mutate(citing_id = str_extract(citing_id, "(?<=2-s2\\.)[0-9]+"))
  return(articles)
}

reformat_references <- function(references) {
  references$sourcetitle <- toupper(references$sourcetitle)
  references <- rename(references,
                       cited_id = id,
                       citing_id = citing_eid,
                       cited_title = sourcetitle,
                       cited_year = publicationyear)

  references <- references |> mutate(citing_id = str_extract(citing_id, "(?<=2-s2\\.)[0-9]+"))
  return(references)
}

