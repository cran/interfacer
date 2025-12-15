## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(interfacer)

## -----------------------------------------------------------------------------
i_test = iface(
  id = integer ~ "an integer ID",
  test = logical ~ "the test result"
)

# Extends the i_test to include an additional column
i_test_extn = iface(
  i_test,
  extra = character ~ "a new value",
  .groups = FALSE
)

## -----------------------------------------------------------------------------

# The generic function
disp_example = function(x, ...) {
  idispatch(x,
    disp_example.extn = i_test_extn,
    disp_example.no_extn = i_test
  )
}

# The handler for extended input dataframe types
disp_example.extn = function(x = i_test_extn, ...) {
  message("extended data function")
  return(colnames(x))
}

# The handler for non-extended input dataframe types
disp_example.no_extn = function(x = i_test, ...) {
  message("not extended data function")
  return(colnames(x))
}

## -----------------------------------------------------------------------------

tmp = tibble::tibble(
    id=c("1","2","3"),
    test = c(TRUE,FALSE,TRUE),
    extra = 1.1
)

tmp %>% disp_example()

## -----------------------------------------------------------------------------
# this matches the i_test_extn specification:
tmp2 = tibble::tibble(
    id=c("1","2","3"),
    test = c(TRUE,FALSE,TRUE)
)

tmp2 %>% disp_example()

## -----------------------------------------------------------------------------
 # This specification requires that the dataframe is grouped only by the color
 # column
i_diamond_price = interfacer::iface(
   color = enum(`D`,`E`,`F`,`G`,`H`,`I`,`J`, .ordered=TRUE) ~ "the color column",
   price = integer ~ "the price column",
   .groups = ~ color
 )

## -----------------------------------------------------------------------------
# An example function which would be exported in a package
# This function expects a dataframe with a colour and price column, grouped
# by price.
mean_price_by_colour = function(df = i_diamond_price, extra_param = ".") {

   # When called with a dataframe with extra groups `igroup_process` will
   # regroup the dataframe according to the structure
   # defined for `i_diamond_price` and apply the inner function to each group
   # after first calling `ivalidate` on each group.

   igroup_process(df,
     # the real work of this function is provided as an anonymous inner
     # function (but can be any other function e.g. package private function
     # but not a purrr style lambda). Ideally this function parameters are named the
     # same as the enclosing function (here `mean_price_by_colour(df,extra_param)`), however
     # there is some flexibility here. The special `.groupdata` parameter will
     # be populated with the values of the unexpected grouping.

     function(df, extra_param, .groupdata) {
       message(extra_param, appendLF = FALSE)
       if (nrow(.groupdata) == 0) message("N.B. zero length group data")
       return(df %>% dplyr::summarise(mean_price = mean(price)))
     }

   )
 }

## -----------------------------------------------------------------------------
# The correctly grouped dataframe. The `ex_mean` function calculates the mean
 # price for each `color` group.
 ggplot2::diamonds %>%
   dplyr::group_by(color) %>%
   mean_price_by_colour(extra_param = "without additional groups... ") %>%
   dplyr::glimpse()

## -----------------------------------------------------------------------------
ggplot2::diamonds %>%
  dplyr::group_by(cut, color, clarity) %>%
  mean_price_by_colour() %>%
  dplyr::glimpse()

## -----------------------------------------------------------------------------
 recursive_example = function(df = i_diamond_price) {

   # call enclosing function recursively if additional groups detected
   igroup_process(df)
   
   # code after this point is only executed if the grouping is correct
   # it will be executed once per additional group.
   # it must return a dataframe
   return(tibble::tibble("rows detected:"=nrow(df)))
   
 }

# this input is grouped as the specification is expecting
# the i_group_process does nothing.
 ggplot2::diamonds %>% dplyr::group_by(color) %>%
    recursive_example() %>%
    dplyr::glimpse()
 
# this input has additional grouping beyond the specification but is handled 
# gracefully
 ggplot2::diamonds %>% dplyr::group_by(cut,clarity,color) %>%
    recursive_example() %>%
    dplyr::glimpse()

