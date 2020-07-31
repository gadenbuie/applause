
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
