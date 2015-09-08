# generator-igemwiki

[Yeoman](http://yeoman.io/) generator for [iGEM](http://igem.org/Main_Page)
wikis. Sets up a development environment with the ability to push entire
codebase (including images) to live wiki pages.

## Install

### kek bro, whats the package name?

```
npm install -g generator-igemwiki
```

### Node.js

This generator requires that you have [Node.js](https://nodejs.org/en/)
installed on your system. If you are on OS X or Linux system, I recommend
installing using [one of these methods](https://gist.github.com/isaacs/579814)
to avoid having to `sudo`. Furthermore [see
here](https://github.com/sindresorhus/guides/blob/master/npm-global-without-sudo.md)
to set up npm packages to install into a custom global directory without sudo.
You can check if the install worked by running

```
node -v
```

in a terminal; it should return the version number. You don't need to worry
about sudo on Windows, as Windows runs as admin by default. However, you may
face some `PATH` issues on Windows (see below).

### NPM

[NPM]((https://www.npmjs.com/) is *node package manager* and is the "largest
ecosystem of open source libraries in the world". All of this project's
dependencies are held on npm, and this package is published on npm.

Node comes with npm, though it is usually not the latest version, and more
importantly, it is not located where your global npm modules are installed.
Before continuing, you should make sure your `PATH` variable catches the correct
npm binary, or in simpler terms, running

```
npm -v
npm install -g npm
npm -v
```

should return a different value on the second `npm -v`. (You may need to open
and close the terminal first). If it is not, compare the path returned by `npm
install -g npm` (of the format path -> path) to `which npm`. If they are
different, it is because the directory containing Node's npm is earlier in your
`PATH` than the one containing the binaries of npm's global modules. For
example, I have the following in my `.bashrc`:

```
# Node and NPM
export NPM_PACKAGES="$HOME/node/npm-packages"
export NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"
export PATH="$PATH:$NPM_PACKAGES/bin:$HOME/node/bin"
export MANPATH="$NPM_PACKAGES/share/man:$MANPATH"
```

You can see `PATH` is the original PATH, followed by npm-packages, followed by
node. On OS X and Linux, you can add the above to your `.bashrc` or `.profile`,
etc. to achieve the same effect. To see your environment's `PATH`, run `echo
$PATH`. Note, I used the two methods mentioned above for not using sudo with
Node and npm, with custom folder names (`node`, and `npm-packages`). On Windows,
you can go to System -> Advanced Settings -> Environment Variables -> Path and
edit it there.

### Yeoman

[Yeoman](http://yeoman.io/) is "the Web's scaffoldig tool for modern webapps".
To get it, install it globally with npm:

```
npm install -g yo
```

Once that is done, you can invoke the Yeoman with `yo`

#### Generator

Now we just need to install this generator:

```
npm install -g generator-igemwiki
```

## Usage

Create a new project folder, `cd` into it (this generator dumps files into the
current directory), and run

```
yo igemwiki
```

You will be asked for
* the year (will default to current year)
* team name is it appears **exactly** on the wiki (needed for push to live wiki)
* author (optional)
* [GitHub](https://github.com/) repo in the format *username/repo*
	* **Why?** As you will see, this generator exposes features which it make it
	  applicable for **collobarative content editing** when using the repo to
	  modify markdown files.
	* Still confused? You can skip this by passing in the option `--skip-repo`.
	  You can always push to a repo later.

### Options

```
yo igemwiki --skip-install --skip-repo
```

`--skip-install` will prevent `bower install` and `npm install` from
automatically running. Use this if you know you need sudo to npm install and it
won't work anyways. `--skip-repo` will prevent the prompt asking you for your
repository.

## Tools

This generator is built using the following tools. You should have an idea what
they are each doing in order to use them effectively.

### Bower

[Bower](http://bower.io/) is "a package manager for the web". Use it to install
frontend dependencies, such as [bootstrap](http://getbootstrap.com/) or
[fontawesome](https://fortawesome.github.io/Font-Awesome/) (*todo: push font
files to wiki**). Install packages like so:

```
bower install --save bootstrap
```

The `--save` is important as it adds bootstrap to the dependencies object in the
`bower.json` file, and will be used by
[wiredep](https://github.com/taptapship/wiredep) to inject the proper css and
script tags into the outputted html. Browser all the Bower packages
[here](http://bower.io/search/).

### Gulp

[Gulp](http://gulpjs.com/) is a JavaScript task runner. It is the tool running
everything behind the development environment, build scripts, and push to live
wiki. You don't need to understand it's internals, and I will go over the tasks
it provides. Everything is in the
[gulpfile](https://github.com/igemuoftATG/generator-igemwiki/blob/master/generators/app/templates/gulpfile.coffee).
Feel free to add your own tasks and submit a pull request!

### Handlebars

[Handlebars](http://handlebarsjs.com/) is used to write templates. This
templates, when combined with helper functions and a set of object values can be
very powerful. This is how I am building links for development and live using
the same source files. The custom helper functions are all [here](https://github.com/igemuoftATG/generator-igemwiki/blob/master/generators/app/templates/helpers.coffee).
This file is much smaller than the gulpfile, and I encourage you to quickly take a look.
Using it, we can do things like:

```
{{capitals teamName}}
```

To get

```
TORONTO
```

Again, if you write your own helper functions which may be useful to other
teams, send a pull request!

### Markdown

Markdown is easy to learn. Markdown provides a way to write clunky HTML without
having to write clunky HTML. Huh?

Consider this html for a level 1 heading:

```html
<h1> Wheeeeee </h1>
```

Okay, that works, but in markdown it is sooo much cleaner:

```
# Wheeeeee
```

You can use `#` to `######` for `<h1>` to `<h6>`, respectably. Still not convinced?

```html
<img src="http://45.55.193.224/logo_grey.png" />
<ul>
	<li> <a href="http://igemuoft.github.io">iGEM UofT Computational Biology</a> </li>
	<li> <b>wheeeee</b> </li>
	<li> <i>wahooooooo</i> </li>
</ul>
```

vs.

```md
![logo](http://45.55.193.224/logo_grey.png)
* [iGEM UofT Computational Biology](http://igemuft.github.io)
* **wheeeeee**
* *wahooooo*
```

Oh and by the way, you just learned markdown. Still curious? See this [Markdown
Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet).

## Tasks

Gulp tasks are run with `gulp taskName`. A lot of the tasks in the gulpfile are
used internally within other tasks, though these are two you will most
commonly run:

### Default

```
gulp
```

Compiles sass, bundles CoffeeScript and JS, compiles handlebars templates,
compiles markdown, and provides a local version of the wiki at
`http://localhost:3000` using [Browsersync](http://www.browsersync.io/). (Which
also sets up a UI at `3001` and an external IP to use from your phone, all
connected!)

### Push

```
gulp push
```

Runs `build:live` and then `push`. Same as above but uses `live` mode when
compiling templates, and minifies Bower css into `vendor.min.css`, personal css
into `styles.min.css`. Likewise for JS, except it uglifies as well, and personal
JS goes into `bundle.min.js`. Then using the
[request](https://www.npmjs.com/package/request) package (in combination with
Chrome's web inspector Network tab), I've emulated to "go to
pageName?action=edit, copy/paste into textbox, click save". You will be asked
for your username and password of course, and will automatically log out when
all uploads are complete.

### Pull

```
gulp pull
```

Run this to download all current live files into `./pulled`.

## Important Files

### Template

The main template file is at `./src/template.json`. This stores the team name,
year, links, markdown files, and navigation bar settings. It's used in almost
every helper function in `./helpers.coffee`, and has a mode, either `dev` or
`live` appended into it by the gulpfile before being used with handlebars.
If you want to add new pages, change the ordering of the navigation, add new
markdown files, edit this.

### Styles

Page styles are stored in `./src/sass`. There is a file there, `styles.scss`
which gets compiled into `./build-dev/css/styles.css`. All the other files here
are prefixed with `_` so that they don't compile for themselves (they are
imported within `styles.scss`). [Sass](http://sass-lang.com/) lets you use
variables and functions in CSS, and is super awesome. It's very easy to learn,
if you already know css, you know sass.

### Scripts

You can write JS and CoffeeScript inside `./src/lib`. You can use `require` syntax
because [Browserify](http://browserify.org/) is employed. Everything here will
get bundled into `./build-dev/js/bundle.js`

### Pages

Pages are written as Handlebars templates in `./src/*.hbs`.

### Markdown

Markdown files are stored in `./src/markdown/*.md`. You can also write inline
markdown using the `markdownHere` helper.

### Images

Images are stored in `./src/images`. They will have `teamName_YEAR_` appended
to the filename when uploading. `images.json` will store a link to the full
resolution of each image.

## Helper Functions

For complete detail, read through
[helpers.coffee](https://github.com/igemuoftATG/generator-igemwiki/blob/master/generators/app/templates/helpers.coffee).
Here is a summary of the helper functions which take parameters (other than
`mode`, which is injected into a new template as either `dev` or `live` for the
`build:dev` and `build:live` tasks, respectably).

### images(image, format, mode)

`image` is the filename exactly as it appears in `./images`, including the
extension. `format` can be:
* "file" -> inline image using wiki code. forces breaking/reopening html
* "media" -> wiki code link to image without showing image, same as above with regards to html
* "directlink" -> The preferred method. Requires `images.json` to already store the image link.

## License

MIT: http://jmazz.mit-license.org/
