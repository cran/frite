#' Creates a function that functions identically to the original, but gives execution time
#'
#' Takes any function and returns a function that will behave in a nearly identical
#' manner, but will also return the function's execution time.
#'
#' @param ..f Any function that isn't primitive (sum, list, etc...)
#' @param tic_args A list of arguments to be passed into tic()
#' @param toc_args A list of arguments to be passed into toc()
#'
#' @details Creates a wrapper function around a function call, preceded by tic() and
#'  toc(). The wrapper will be given the same arguments as the original function and
#'  work identically to the original function.
#'
#' @return function
#'
#' @seealso \code{\link{is.output.same}}
#'
#' @export
#'
#' @examples
#'
#' set.seed(1)
#' stuff <- rnorm(n = 100000)
#'
#' lapply_new <- tictocify(lapply)
#' lapply_new(stuff, function(x) x > 0)
#' is.output.same(lapply_new(stuff, function(x) x > 0), lapply)
#'

tictocify <- function(..f, tic_args = NULL, toc_args = NULL) {

  # Error checking
  assert_that(is.function(..f))
  assert_not_primitive(..f)
  if (!is.null(tic_args)) assert_that(is.list(tic_args))
  if (!is.null(toc_args)) assert_that(is.list(toc_args))

  # Creates a wrapper function for a call of ..f
  int_f <- function() {
    ifelse(is.null(tic_args),
           tic(),
           do.call(tic, tic_args))

    x <- do.call(..f, map(.x = names(formals(..f)), .f = as.name))

    ifelse(is.null(toc_args),
           toc(),
           do.call(toc, toc_args))
    return(x)
  }

  # Makes the arguments of int_f identical to the ..f arguments
  formals(int_f) <- formals(..f)
  return(int_f)
}
