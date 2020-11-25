#' log to the local bigbrithr database
#'
#' @param logger logging function
#' @param label label
#'
#' @export
bb_log <- function(logger, label) {
  if(isTRUE(getOption("bigbrother.optin"))) {
    time <- Sys.time()
    bb_env[[as.character(time)]] <- data.frame(
      time = time,
      logger = logger,
      fun = deparse1(eval.parent(quote(match.call()), 2)[[1]]),
      label = label)
  }
  invisible()
}


#' change a function into a bigbrothr loging function
#'
#' As a side effect, a function named `nm` is created in the local environment.
#'
#' @param f the function to bbfy
#' @param nm the name of the function to create
#' @param label_arg the name of the label
#'
#' @export
bbfy <- function(f, nm, label_arg = "label") {
  b <- body(f)
  bb_log_call <-
    bquote(bigbrothr::bb_log(logger = .(nm), label = .(as.symbol(label_arg))))
  if(!is.call(b) || !identical(b[[1]], quote(`{`))) {
    b <- call("{", bb_log_call, b)
  } else {
    b <- as.call(c(quote(`{`), bb_log_call, as.list(b)[-1]))
  }
  body(f) <- b
  if(label_arg %in% names(formals(f)))
    stop("Choose another value for `label_arg`, '",
         label_arg, "' is already taken.")
  formals(f) <- c(formals(f), setNames("", label_arg))
  assign(nm, f, parent.frame())
}
