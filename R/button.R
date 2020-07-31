#' Add an Applause Button to your page
#'
#' Add an applause button to your page or Shiny app that allows users to
#' applaud your excellent work.
#'
#' @references https://applause-button.com/
#'
#' @param style Inline CSS styles
#' @param width,height The width and height of the applause button, for best
#'   results the button should be square.
#' @param color The color of the button as a valid CSS color
#' @param multiclap Should users be allowed to clap more than once?
#' @param url The URL used to track total claps, if unset the current referring page URL will be used
#' @param url_api A URL for a custom Applause button back-end API, see
#'   <https://github.com/ColinEberhardt/applause-button-server> for an example.
#' @param ... Additional attributes for the `<applause-button>` tag
#'
#' @return An [htmltools::tagList()] for an Applause button
#'
#' @export
button <- function(
  ...,
  style = NULL,
  width = "50px",
  height = width,
  color = NULL,
  multiclap = FALSE,
  url = NULL,
  url_api = NULL
) {
  if (!is.null(color)) {
    stopifnot(
      "`color` must be a string" = is.character(color),
      "`color` must be a string" = length(color) == 1
    )
  }

  if (!is.null(style)) {
    stopifnot(
      "`style` must be a string" = is.character(style),
      "`style` must be a string" = length(style) == 1
    )
  }

  multiclap <- if (isTRUE(multiclap)) "true"

  # merge provided width/height into the style attribute
  width <- htmltools::validateCssUnit(width)
  height <- htmltools::validateCssUnit(height)
  style_size <- sprintf("width: %s; height: %s;", width, height)
  style <- paste0(style_size, style)

  tag_attrs <- list(
    ...,
    style = style,
    color = color,
    multiclap = multiclap,
    url = url,
    api = url_api
  )

  htmltools::tagList(
    htmltools::tag("applause-button", tag_attrs),
    html_dependency_applause()
  )
}
