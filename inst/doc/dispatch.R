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

# generic type 1 input
i_input_1 = iface(
  x = integer ~ "the positives",
  n = default(100) + integer ~ "the total"
)

# generic type 2 input
i_input_2 = iface(
  p = proportion ~ "the proportion",
  n = default(100) + integer ~ "the total"
)

# more detailed combined type 1 and 2 input
i_interim = iface(
  i_input_1,
  i_input_2
)

# most detailed input format
i_final = iface(
  i_interim,
  lower = double ~ "wilson lower CI",
  upper = double ~ "wilson lower CI",
  mean = double ~ "wilson mean"
)

# final target output format
i_target = iface(
  i_final,
  label = character ~ "a printable label"
)

# processes input of type 1 and 
process.input_1 = function(x = i_input_1,...) {
  message("process input 1")
  ireturn(x %>% dplyr::mutate(p = x/n), iface = i_interim)
}

process.input_2 = function(x = i_input_2,...) {
  message("process input 2")
  ireturn(x %>% dplyr::mutate(x = floor(p*n)), iface = i_interim)
}

process.interim = function(x) {
  message("process interim")
  ireturn(x %>% dplyr::mutate(binom::binom.wilson(x,n)), iface = i_final)
}

process.final = function(x) {
  message("process final")
  ireturn(x %>% dplyr::mutate(label = sprintf("%1.1f%% [%1.1f%% - %1.1f%%] (%d/%d)", 
    mean*100, lower*100, upper*100, x, n)), iface = i_target)
}

process = function(x,...) {
  # this test must be at the front to prevent infinite recursion
  if (itest(x, i_target)) return(x)
  out = idispatch(x,
    process.final = i_final,
    process.interim = i_interim,
    process.input_2 = i_input_2,
    process.input_1 = i_input_1
  )
  return(process(out))
}


## -----------------------------------------------------------------------------
# tibble::tibble(x=c(10,30), n=c(NA,50)) %>% itest(i_input_1)
process(tibble::tibble(x=c(10,30), n=c(NA,50))) %>% dplyr::glimpse()

## -----------------------------------------------------------------------------
# tibble::tibble(p=0.15,n=1000) %>% itest(i_input_2)
process(tibble::tibble(p=0.15,n=1000)) %>% dplyr::glimpse()

## -----------------------------------------------------------------------------
i_diamond_price = interfacer::iface(
  color = enum(`D`,`E`,`F`,`G`,`H`,`I`,`J`, .ordered=TRUE) ~ "the color column",
  price = integer ~ "the price column",
  .groups = ~ color
)

## -----------------------------------------------------------------------------
 # exported function in package
 # at param can use `r idocument(ex_mean, df)` for documentation
 ex_mean = function(df = i_diamond_price, extra_param = ".") {

   # dispatch based on groupings:
   igroup_process(df,

     # the real work of this function is provided as an anonymous inner
     # function (but can be any other function e.g. package private function)
     # or a purrr style lambda.

     function(df, extra_param) {
       message(extra_param, appendLF = FALSE)
       return(df %>% dplyr::summarise(mean_price = mean(price)))
     }

   )
 }

## -----------------------------------------------------------------------------
# The correctly grouped dataframe
ggplot2::diamonds %>%
  dplyr::group_by(color) %>%
  ex_mean(extra_param = "without additional groups...") %>%
  dplyr::glimpse()

## -----------------------------------------------------------------------------
# The incorrectly grouped dataframe
ggplot2::diamonds %>%
  dplyr::group_by(cut, color) %>%
  ex_mean() %>%
  dplyr::glimpse()


