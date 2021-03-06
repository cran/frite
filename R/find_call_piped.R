#' Finds the call that generated the value that was passed through a pipe.
#'
#' This function that receives a value through a pipe, then traces it through the stack to
#' find the original pipe call and returns it. The usage for this is when you want to write
#' a function that receives code rather than a value. You can put it as the first line of code
#' in your function to enable code to be piped. However, this defeats the purpose of the pipe
#' and can cause confusion for someone looking at your code.
#'
#' @param .piped A value passed through a pipe.
#'
#' @return call
#'

find_call_piped <- function(.piped) {

  # A function that wraps the parent.frame() tail() and head_while()
  pipe_env <- purrr::compose(parent.frame,
                             purrr::partial(utils::tail, n = 3),
                             purrr::head_while)

  # Returns the last environment in which 'chain_parts' exists
  env <- pipe_env(1:sys.nframe(),
                  function(.n) {
                    !("chain_parts" %in% ls(envir = parent.frame(.n)))
                  })

  # Returns code at top of the pipe chain, returns .piped code if nothing piped
  if (exists("chain_parts", env)) {
    warning("You have undone the evaluation of the pipe")
    return(env$chain_parts$lhs)
  } else {
    return(do.call("substitute", list(substitute(.piped), parent.frame())))
  }
}
