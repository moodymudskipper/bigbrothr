#' @importFrom utils sessionInfo View
#' @importFrom stats setNames
NULL

bb_env <- new.env()

bb_upload <- function(data, session_info) {
  message("fake uploading...")
  print(data)
}

bb_prompt <- function() {
  if(isTRUE(getOption("bigbrother.optin"))) {
    if(!isFALSE(getOption("bigbrothr.prompt"))  && curl::has_internet()) {
      data <- as.data.frame(do.call(Map, c(quote(c),as.list(bb_env))))
      session_info <- sessionInfo()
      session_info$loadedOnly   <- NULL
      session_info$otherPkgs <- NULL

      if(nrow(data)) data <- data[order(data$time),]
      row.names(data) <- NULL
      prompt <- "" # default to be overwritten
      message(
        "Do you agree to upload your {bigbrothr} logs ? ",
        "\n- Add `options(bigbrothr.prompt = FALSE)` to your RProfile to agree by default",
        "\n- Add `options(bigbrothr.optin = FALSE)`  to your RProfile to always decline and not to see this prompt again")
      while(!prompt %in% c("y", "n")) {
        prompt <- readline("y/n/inspect: ")
        #if(!prompt %in% c("y", "n", "inspect")) message("wrong input")
        if(prompt == "inspect") {
          print(session_info)
          View(data)
        }
      }
    } else {
      prompt <- "y"
    }

    if(prompt == "y") {
      bb_upload(data)
    }
  }
}

.onLoad <- function(libname, pkgname){
  if(exists(".Last", .GlobalEnv)) {
    # trace existing .Last with call to bb_prompt
    suppressMessages(
      trace(.Last, quote(getFromNamespace("bb_prompt", "bigbrothr")()))
    )
  }
  .Last <<- bb_prompt
  #assign(".Last", bb_prompt, .GlobalEnv)

  # reg.finalizer doesn't seem to work right
  # reg.finalizer(.GlobalEnv, bb_prompt, onexit = TRUE)

  if(!isTRUE(getOption("bigbrother.optin")))
    bb_startup()
}

bb_startup <- function() {
  packageStartupMessage(
  "{bigbrother} was loaded.\nTo allow safe usage information collection ",
  "and help package maintainers, ",
  "set `options(bigbrother.optin = TRUE)` in your RProfile, ",
  "then this message won't be shown anymore but you will be prompted before uploading, unless you also set ",
  "`options(bigbrother.prompt = FALSE)`.\n",
  "To opt out permanently, set `options(bigbrother.optin = FALSE)` in ",
  "your RProfile and you won't see this message anymore.")
}
