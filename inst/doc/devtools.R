## ----eval=FALSE---------------------------------------------------------------
#  #' A function
#  #'
#  #' @iparam df An input dataframe
#  #' @return ... something ...
#  test_function = function(df = interfacer::iface(col1 = integer ~ "An integer value")) {
#    df = interfacer::ivalidate(df)
#    # ... main function body ...
#  }

## ----eval=FALSE---------------------------------------------------------------
#  
#  # This may be defined in the file R/interfaces.R
#  i_type1 = interfacer::iface(col1 = integer ~ "An integer value")
#  i_type2 = interfacer::iface(col1 = date ~ "A date value")
#  
#  #' A mulitple dispatch function
#  #'
#  #' @param df An input dataframe conforming to one of:
#  #' `r interfacer::idocument(test_function.type1, df)`
#  #' or
#  #' `r interfacer::idocument(test_function.type2, df)`
#  #'
#  #' @return ... something ...
#  test_function = function(df) {
#    interfacer::idispatch(df,
#      test_function.type1 = i_type1,
#      test_function.type2 = i_type2
#    )
#  }
#  
#  test_function.type1 = function(df = i_type1) {
#    # ... deal with integer input ...
#  }
#  
#  test_function.type1 = function(df = i_type2) {
#    # ... deal with date input ...
#  }
#  

## ----eval=FALSE---------------------------------------------------------------
#  
#  # This may be defined in the file R/interfaces.R
#  i_input_type = interfacer::iface(col1 = integer ~ "An integer value")
#  i_return_type = interfacer::iface(output = date ~ "A date value")
#  
#  #' An example function
#  #'
#  #' @param df An input dataframe conforming to:
#  #' `r i_input_type`
#  #'
#  #' @return a dataframe of the following format:
#  #' `r i_return_type`
#  test_function = function(df = i_input_type) {
#    df = interfacer::ivalidate(df)
#    # ... main function body ...
#    interfacer::ireturn( ...output... , i_return_type)
#  }
#  
#  

