

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
