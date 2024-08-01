## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(interfacer)

## -----------------------------------------------------------------------------

tmp = iris %>% 
  tidyr::nest(by_species = -Species) %>%
  dplyr::mutate(
    model = purrr::map(by_species, ~ stats::lm(Sepal.Length ~ Sepal.Width, .x)),
    quantiles = purrr::map(by_species, ~ sapply(.x, quantile))
  )

tmp %>% dplyr::glimpse()


## -----------------------------------------------------------------------------

# Pasted from `iclip(tmp)` with minor modification:
i_tmp = interfacer::iface(
	Species = enum(`setosa`,`versicolor`,`virginica`) ~ "the Species column",
	by_species = list(i_by_species) ~ "the by_species column",
	model = list(of_type(lm)) ~ "the model column",
	quantiles = list(matrix) ~ "the quantiles column",
	.groups = NULL
)

i_by_species = interfacer::iface(
	Sepal.Length = numeric ~ "the Sepal.Length column",
	Sepal.Width = numeric ~ "the Sepal.Width column",
	Petal.Length = numeric ~ "the Petal.Length column",
	Petal.Width = numeric ~ "the Petal.Width column",
	.groups = NULL
)

## -----------------------------------------------------------------------------
tmp %>% iconvert(i_tmp) %>% dplyr::glimpse()

## -----------------------------------------------------------------------------

i_diamonds_cat = interfacer::iface(
  cut = enum(`Fair`,`Good`,`Very Good`,`Premium`,`Ideal`, .ordered=TRUE) ~ "the cut column",
  color = enum(`D`,`E`,`F`,`G`,`H`,`I`,`J`, .ordered=TRUE) ~ "the color column",
  clarity = enum(`I1`,`SI2`,`SI1`,`VS2`,`VS1`,`VVS2`,`VVS1`,`IF`, .ordered=TRUE) ~ "the clarity column",
  data = list(i_diamonds_data) ~ "A nested data column must be specified as a list",
  .groups = FALSE
)

i_diamonds_data = interfacer::iface(
  carat = numeric ~ "the carat column",
  depth = numeric ~ "the depth column",
  table = numeric ~ "the table column",
  price = integer ~ "the price column",
  x = numeric ~ "the x column",
  y = numeric ~ "the y column",
  z = numeric ~ "the z column",
  .groups = FALSE
)

nested_diamonds = ggplot2::diamonds %>%
  tidyr::nest(data = c(-cut,-color,-clarity))

system.time(
  nested_diamonds %>% 
    iconvert(i_diamonds_cat) %>% 
    dplyr::glimpse()
)


## -----------------------------------------------------------------------------
try(
  ggplot2::diamonds %>%
    dplyr::select(-price) %>%
    tidyr::nest(data = c(-cut,-color,-clarity)) %>%
    iconvert(i_diamonds_cat) %>% 
    dplyr::glimpse()
)

