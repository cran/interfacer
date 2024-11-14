## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

library(interfacer)

## -----------------------------------------------------------------------------

newton2 = function(f, m = 5, a) {
  # we want to ensure vectorised parameters provided are the same length
  recycle(f,m,a)
  # ensure parameters `f`,`m` and `a` are numeric and coerce them if not.
  check_numeric(f,m,a)
  # fill in missing variables using the relationships given.
  resolve_missing(
    f = m*a,
    a = f/m,
    m = f/a
  )
  # do something useful here...
  return(tibble::tibble(f=f,m=m,a=a))
}

## -----------------------------------------------------------------------------
newton2(f="10",m=2) %>% tibble::glimpse()

## -----------------------------------------------------------------------------
newton2(f=1:10, m=2) %>% tibble::glimpse()

## -----------------------------------------------------------------------------
try(newton2(f=1:10, a=0.5))

## -----------------------------------------------------------------------------
newton2(f=1:10, m=NULL, a=0.5) %>% tibble::glimpse()

## -----------------------------------------------------------------------------
newton2(m=2,a=1:10) %>% tibble::glimpse()

## -----------------------------------------------------------------------------

try(newton2(m=2))

## -----------------------------------------------------------------------------
newton2(f=1:10) %>% tibble::glimpse()

