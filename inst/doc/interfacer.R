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

## ----results='markup'---------------------------------------------------------
cat(print(i_test))

## -----------------------------------------------------------------------------
#' An example function
#'
#' @iparam mydata a dataframe input which should conform to `i_test`
#' @param another an example
#' @param ... not used
#'
#' @return the conformant dataframe
#' @export
example_fn = function(
  mydata = i_test,
  another = "value",
  ...
) {
  mydata = ivalidate(mydata)
  return(mydata)
}

## -----------------------------------------------------------------------------

example_data = tibble::tibble(
    id = c(1,2,3), # this is a numeric vector
    test = c(TRUE,FALSE,TRUE)
  )

# this returns the qualifying data
example_fn(
  example_data, 
  "value for another"
) %>% dplyr::glimpse()

## -----------------------------------------------------------------------------
bad_example_data = tibble::tibble(
    id = c(1,2,3),
    wrong_name = c(TRUE,FALSE,TRUE)
  )

# this causes an error as example_data_2$wrong_test is wrongly named
try(example_fn(
  bad_example_data, 
  "value for another"
))

## -----------------------------------------------------------------------------
bad_example_data_2 = tibble::tibble(
    id = c(1, 2.1, 3), # cannot be cleanly coerced to integer.
    test = c(TRUE,FALSE,TRUE)
  )

try(example_fn(
  bad_example_data_2, 
  "value for another"
))

## -----------------------------------------------------------------------------
i_test_extn = iface(
  i_test,
  extra = character ~ "a new value",
  .groups = FALSE
)

print(i_test_extn)

## -----------------------------------------------------------------------------

#' Another example function 
#' 
#' @iparam mydata a more constrained input
#' @param another an example   
#' @param ... not used
#'
#' @return `r i_test`
#' @export
example_fn2 = function(
    mydata = i_test_extn,
    ...
) {
  mydata = ivalidate(mydata, ..., .prune = TRUE)
  mydata = mydata %>% dplyr::select(-extra)
  # check the return value conforms to a new specification
  ireturn(mydata, i_test)
}

## -----------------------------------------------------------------------------
grouped_example_data = tibble::tibble(
    id = c(1,2,3),
    test = c(TRUE,FALSE,TRUE),
    extra = c("a","b","c"),
    unneeded = c("x","y","z")
  ) %>% dplyr::group_by(id)

## -----------------------------------------------------------------------------
try(example_fn2(grouped_example_data))

## -----------------------------------------------------------------------------
grouped_example_data %>% 
  dplyr::ungroup() %>% 
  example_fn2() %>% 
  dplyr::glimpse()

## -----------------------------------------------------------------------------

i_diamonds = interfacer::iface(
	carat = numeric ~ "the carat column",
	color = enum(`D`,`E`,`F`,`G`,`H`,`I`,`J`, .ordered=TRUE) ~ "the color column",
	x = numeric ~ "the x column",
	y = numeric ~ "the y column",
	z = numeric ~ "the z column",
	# This specifies a permissive grouping with at least `carat` and `cut` columns
	.groups = ~ . + carat + cut
)

if (rlang::is_installed("ggplot2")) {
  
  # permissive grouping with the `~ . + carat + cut` groups rule
  ggplot2::diamonds %>% 
    dplyr::group_by(color, carat, cut) %>% 
    # in a usual workflow this would be an `ivalidate` call within a package 
    # function but for this example we are directly calling the underlying function
    # `iconvert`
    iconvert(i_diamonds, .prune = TRUE) %>% 
    dplyr::glimpse()

}

## -----------------------------------------------------------------------------
cat(idocument(example_fn2))

## -----------------------------------------------------------------------------

tibble::tibble(
  id=c("1","2","3"),
  test = c(TRUE,FALSE,TRUE),
  extra = 1.1
) %>%
example_fn2() %>% 
dplyr::glimpse()


## -----------------------------------------------------------------------------
try(example_fn(
  tibble::tibble(
    id= c("1.1","2","3"),
    test = c(TRUE,FALSE,TRUE)
  )))

## -----------------------------------------------------------------------------

if (rlang::is_installed("ggplot2")) {
  
  i_diamonds = iface( 
    color = enum(D,E,F,G,H,I,J,extra) ~ "the colour",
    cut = enum(Ideal, Premium, .drop=TRUE) ~ "the cut",
    price = integer ~ "the price"
  )
  
  ggplot2::diamonds %>% 
    iconvert(i_diamonds, .prune = TRUE) %>% 
    dplyr::glimpse()
   
} 

## ----echo=FALSE---------------------------------------------------------------
tmp = help.search(package = "interfacer", pattern = "type\\..*")
tmp$matches %>% 
  dplyr::transmute(Topic = stringr::str_remove(Topic, "type\\."), Title) %>%
  knitr::kable()
  

## ----eval=FALSE---------------------------------------------------------------
#  iface(
#    col1 = double + finite ~ "A finite double",
#    col2 = integer + in_range(0,100) ~ "an integer in the range 0 to 100 inclusive",
#    col3 = numeric + in_range(0,10, include.max=FALSE) ~ "a numeric 0 <= x < 10",
#    col4 = date ~ "A date",
#    col5 = logical + not_missing ~ "A non-NA logical",
#    col6 = logical + default(TRUE) ~ "A logical with missing (i.e. NA) values coerced to TRUE",
#    col7 = factor ~ "Any factor",
#    col8 = enum(`A`,`B`,`C`) + not_missing ~ "A factor with exactly 3 levels A, B and C and no NA values"
#  )

## -----------------------------------------------------------------------------
uppercase = function(x) {
  if (any(x != toupper(x))) stop("not upper case input",call. = FALSE)
  return(x)
}

custom_eg = function(df = iface(
  text = character + uppercase ~ "An uppercase input only"
)) {
  df = ivalidate(df)
  return(df)
}

tibble::tibble(text = "SUCCESS") %>% custom_eg()

try(tibble::tibble(text = "fail") %>% custom_eg())


## -----------------------------------------------------------------------------

# Coerce the `date_col` to a POSIXct and 
custom_eg_2 = function( df = iface(
    date_col = POSIXct ~ "a posix date",
    ts_col = of_type(ts) ~ "A timeseries vector"
  )) {
  df = ivalidate(df)
  return(lapply(df, class))
}

tibble::tibble(
  date_col = c("2001-01-01","2002-01-01"),
  ts_col = ts(c(2,1))
) %>% custom_eg_2()


## -----------------------------------------------------------------------------

i_iris = interfacer::iface(
	Sepal.Length = numeric ~ "the Sepal.Length column",
	Sepal.Width = numeric ~ "the Sepal.Width column",
	Petal.Length = numeric ~ "the Petal.Length column",
	Petal.Width = numeric ~ "the Petal.Width column",
	Species = enum(`setosa`,`versicolor`,`virginica`) ~ "the Species column",
	.groups = NULL,
  .default = TRUE
)

test_fn = function(i = i_iris, ...) {
  # if i is not provided (a missing value) the default zero length 
  # dataframe defined by `i_iris` is used.
  i = ivalidate(i)
  return(i)
}

# Outputs a zero length data frame as the default value
test_fn() %>% dplyr::glimpse()


## -----------------------------------------------------------------------------

i_iris_2 = interfacer::iface(
	Sepal.Length = numeric ~ "the Sepal.Length column",
	Sepal.Width = numeric ~ "the Sepal.Width column",
	Petal.Length = numeric ~ "the Petal.Length column",
	Petal.Width = numeric ~ "the Petal.Width column",
	Species = enum(`setosa`,`versicolor`,`virginica`) ~ "the Species column",
	.groups = NULL,
  .default = iris
)

test_fn_2 = function(i = i_iris_2, ...) {
  i = ivalidate(i)
  return(i)
}

# Outputs the 150 row iris data frame as a default value from the definition of `i_iris_2`
test_fn_2() %>% dplyr::glimpse()


## -----------------------------------------------------------------------------

test_fn_3 = function(i = i_iris_2, ...) {
  i = ivalidate(i, .default = iris %>% head(5))
  return(i)
}

# Outputs the first 5 rows of the iris data frame as the default value
test_fn_3() %>% dplyr::glimpse()


