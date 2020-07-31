
# applause

<!-- badges: start -->
<!-- badges: end -->

[applause-button]: https://applause-button.com/
[ColinEberhardt]: https://github.com/ColinEberhardt/
[htmltools]: https://github.com/ColinEberhardt/
[npm]: https://www.npmjs.com/

Add an _applause button_ to your web pages, blog posts, and Shiny apps. Based entirely on the awesome [applause-button] library by [Colin Eberhardt][ColinEberhardt].

The other goal of this project is to demonstrate how to use HTML dependencies with the [htmltools] package.


## Dev Log

```r
library(usethis)
create_package("applause")
use_readme_md()
```

Create a directory in `inst` to hold the applause button dependencies.

```r
dir.create("inst/applause-button", recursive = TRUE)
```

In a terminal, initialize an [npm] project in the package root to create a `package.json`. There are a few ways this can be done, but I prefer to have `package.json` and `npm` manage the JavaScript dependency.

```sh
# In terminal, hit enter to accept most defaults, or change what you want
npm init
```
