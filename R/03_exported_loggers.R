#' bb_stop
#'
#' bbfied stop
#' @inheritParams base::stop
#' @param label label in bigbrothr database
#' @export
bb_stop <- function(..., call. = TRUE, domain = NULL, label = "") {
  # for cmd check
  int <- .Primitive(".Internal")
  .signalCondition <- .dfltStop <- NULL
  bb_log(logger = "bb_stop",label = label)
  args <- list(...)
  if (length(args) == 1L && inherits(args[[1L]], "condition")) {
    cond <- args[[1L]]
    if (nargs() > 1L)
      warning("additional arguments ignored in stop()")
    message <- conditionMessage(cond)
    call <- conditionCall(cond)
    int(.signalCondition(cond, message, call))
    int(.dfltStop(message, call))
  }
  else int(stop(call., .makeMessage(..., domain = domain)))
  #stop(..., call. = call., domain = domain)
}

#' bb_warning
#'
#' bbfied warning
#' @inheritParams base::warning
#' @param label label in bigbrothr database
#' @export
bb_warning <- function (..., call. = TRUE, immediate. = FALSE, noBreaks. = FALSE,
                        domain = NULL, label = "") {
  # for cmd check
  int <- .Primitive(".Internal")
  .signalCondition <- .dfltWarn <- NULL

  bb_log(logger = "bb_warning",label = label)
  args <- list(...)
  if (length(args) == 1L && inherits(args[[1L]], "condition")) {
    cond <- args[[1L]]
    if (nargs() > 1L)
      cat(gettext("additional arguments ignored in warning()"),
          "\n", sep = "", file = stderr())
    message <- conditionMessage(cond)
    call <- conditionCall(cond)
    withRestarts({
      int(.signalCondition(cond, message, call))
      int(.dfltWarn(message, call))
    }, muffleWarning = function() NULL)
    invisible(message)
  }
  else int(warning(call., immediate., noBreaks., .makeMessage(...,
                                                                    domain = domain)))
}


#' bb_message
#'
#' bbfied message
#' @inheritParams base::message
#' @param label label in bigbrothr database
#' @export
bb_message <- function (..., domain = NULL, appendLF = TRUE, label = "") {
  bb_log(logger = "bb_message",label = label)
  args <- list(...)
  cond <- if (length(args) == 1L && inherits(args[[1L]], "condition")) {
    if (nargs() > 1L)
      warning("additional arguments ignored in message()")
    args[[1L]]
  }
  else {
    msg <- .makeMessage(..., domain = domain, appendLF = appendLF)
    call <- sys.call()
    simpleMessage(msg, call)
  }
  defaultHandler <- function(c) {
    cat(conditionMessage(c), file = stderr(), sep = "")
  }
  withRestarts({
    signalCondition(cond)
    defaultHandler(cond)
  }, muffleMessage = function() NULL)
  invisible()
}
