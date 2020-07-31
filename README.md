
# applause

<!-- badges: start -->
<!-- badges: end -->

[applause-button]: https://applause-button.com/
[ColinEberhardt]: https://github.com/ColinEberhardt/
[htmltools]: https://github.com/ColinEberhardt/
[npm]: https://www.npmjs.com/

Add an _applause button_ to your web pages, blog posts, and Shiny apps. Based entirely on the awesome [applause-button] library by [Colin Eberhardt][ColinEberhardt].

The other goal of this project is to demonstrate how to use HTML dependencies with the [htmltools] package.

## Installation

```r
# install.packages("remotes")

remotes::install_github("gadenbuie/applause")
```

## Demonstration and Usage

[See `applause::button()` in action](https://gadenbuie.github.io/applause).

## Dev Log

### Package Init

```r
library(usethis)
create_package("applause")
use_readme_md()
```

Create a directory in `inst` to hold the applause button dependencies.

```r
dir.create("inst/applause-button", recursive = TRUE)
```

### Setup npm to import the JavaScript package

In a terminal, initialize an [npm] project in the package root to create a `package.json`. There are a few ways this can be done, but I prefer to have `package.json` and `npm` manage the JavaScript dependency.

```sh
# In terminal, hit enter to accept most defaults, or change what you want
npm init
```

Use `npm` to install the [applause-button] dependencies.

```sh
npm install applause-button
```

This step will install `applause-button` and it's related dependencies into `node_modules/`. It will also create a `package-lock.json` file that should be committed alongside `package.json`, but we don't want to commit the dependencies yet. In fact, we add those to build and git ignore files.

```r
use_build_ignore("package.json")
use_build_ignore("package-lock.json")
use_build_ignore("node_modules/")
use_git_ignore("node_modules/")
```

### Move the JavaScript dependencies into the R package

Now we need to move the `applause-button` dependencies into our R package space. If you look inside `node_modules/` you'll find the `applause-button/` folder, which contains the library source and a `dist/` directory where the JavaScript and CSS dependencies are stored.
We need to copy these files from `node_modules/applause-button/dist` to `inst/applause-button/`.

I usually do this with `npm` so that it's handled by the JavaScript package manager and so that I don't forget to do this step. I use an npm package called `copyfiles`, which is added as a dev dependency.

```sh
npm install --save-dev copyfiles
```

Then I add the following to `package.json` in `"scripts"`.

```json
"scripts": {
  "copy": "copyfiles -f \"node_modules/applause-button/dist/applause-button.*\" inst/applause-button",
  "build": "npm run copy"
}
```

This creates two [npm run scripts](https://docs.npmjs.com/cli/run-script), a script for the `copy` step and a script for the `build` step. The `build` step at the moment just calls the `copy` step, but if we later decide to add more build steps, this format lets us add on easily.

To move the files where they need to be, run:

```sh
npm run build
```

### Create html_dependency_applause()

Now we turn to building out the R package. First we depend on the [htmltools] package.

```r
use_package("htmltools")
```

Then we create an `html_dependency_applause()` function in `R/html_dependency.R`.

```r
use_r("html_dependency")
```

The function looks like this:

```r
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
```

- The `name` of the dependency is `applause-button` because that's what it's called on npm, i.e. we ran `npm install applause-button`.

- The `version` installed from npm was 3.3.2 (if we update the package later, we'll need to update this function).

- The R `package` providing the dependency is called `applause`

- The `src` directory where the files are located is `applause-button`, corresponding to `inst/applause-button` (the files in `inst/` are installed in the package root directory when the package is installed.)

- The `script` to be loaded is `applause-button.js`

- The `stylesheet` to be loaded is `applause-button.css`

- And just for safety, we set `all_files = FALSE` so that other files in this folder are included when the dependency is used.

The Applause button distribution files are also available via the unpkg CDN, so I updated `src` to include the URL to the directory containing the files. To specify both the local and remote locations of the distribution files, `src` in `htmlDependency()` accepts a named character vector, where the `file` item corresponds to the local path and the `href` item corresponds to the remote URL.

```r
src = c(
  file = "applause-button",
  href = "https://unpkg.com/applause-button@3.3.2/dist"
)
```

### Create UI functions the provide the HTML

The [applause-button] documentation page includes a section showing the HTML required to include an Applause button on your web page:

```html
<head>
  <!-- add the button style & script -->
  <link rel="stylesheet" href="applause-button.css" />
  <script src="applause-button.js"></script>
</head>
<body>
  <!-- add the button! -->
  <applause-button style="width: 58px; height: 58px;"/>
</body>  
```

The HTML dependency function we created above will provide htmltools with enough information to create the `<link>` and `<script>` tags that need to be included in the `<head>` of the page. Our next task is to provide a function that creates the HTML that appears in the page and to attach the `html_dependency_applause()` to that HTML.

The Applause button provides an interesting wrinkle at this step. Rather than using a classed `<div>`, the button uses a custom HTML tag: `<applause-button>`. So the first step is to create an appropriate tag. Again, from the [documentation], this tag can have the following attributes:

- `color`, with a CSS color for the button
- `multiclap`, a binary attribute that when `"true"` allows users to clap more than once
- `url`, the URL used to track total claps, if unset the current referring page URL will be used
- `api`, a URL for a custom Applause button back-end API.

```r
use_r("button")
```

Following the above, I created a [`button()` function](https://github.com/gadenbuie/applause/blob/5f68db6d95ef8585d627b50ac8f1eb3eeaaf94c4/R/button.R) that returns the custom element.

```r
applause::button(color = "red", width = "33px")
## <applause-button style="width: 33px; height: 33px;" color="red"></applause-button>
```

The applause button at this point returns just the custom HTML tag, but doesn't include the dependencies. To include the applause button dependencies, we need to "attach" the `html_dependency_applause()` to the tag. The easiest way to do this is to return an `htmltools::tagList()` containing the HTML tags and the dependencies:

```r
htmltools::tagList(
  button(),
  html_dependency_applause()
)
```

(Sidenote: at this point I'm beginning to question calling the function `button()`, but I think it's okay. This package will have only two exposed functions, and I'll recommend that most people call the fully qualified function name: `applause::button()`.)

### That's it!

The package now provides an HTML dependency and a custom Applause button component that can be dropped into an R Markdown document, a blogdown page, a Shiny app, or a xaringan presentation.

The last step is to add a demonstration page and to update the README!

👏 👏 👏
