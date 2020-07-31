#' @export
html_dependency_applause <- function() {
  htmltools::htmlDependency(
    name = "applause-button",
    version = "3.3.2",
    package = "applause",
    src = "applause-button",
    script = "applause-button.js",
    stylesheet = "applause-button.css",
    all_files = FALSE
  )
}
