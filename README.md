# iGEM Toronto Wiki Generator 2015

Repo for wiki *generator* development.

## Features

The core of this generator is built around compiling one set of
[handlebars](http://handlebarsjs.com/) templates into a `live` and `dev`
version. The `dev` version located within `./build-dev` can be locally hosted
with all *navigational* URIs pointing to local files. On the other hand, the
`live` version located within `./build-live` uses links that follow the iGEM
Wiki namespacing conventions.

* compile `./src/**/*.hbs` into `./build-dev/**/*.html` and `./build-live/**/*.html`
* working handlebars variables inside pages *and* templates

## ToDos

* working templates *within* templates
* implement markdown compiling for page content
* add browserSync to gulpfile

## Guide

### Defining page links

### Creating new pages

### Creating new templates

## Original Toronto Pages

Retrieved from [here](http://2015.igem.org/wiki/index.php?title=Special%3AAllPages&from=Team%3AToronto&to=Team%3AToronto%2FTeam&namespace=0)

* [Team:Toronto](http://2015.igem.org/Team:Toronto)
* [Team:Toronto/Attributions](http://2015.igem.org/Team:Toronto/Attributions)
* [Team:Toronto/Basic_Part](http://2015.igem.org/Team:Toronto/Basic_Part)
* [Team:Toronto/Collaborations](http://2015.igem.org/Team:Toronto/Collaborations)
* [Team:Toronto/Composite_Part](http://2015.igem.org/Team:Toronto/Composite_Part)
* [Team:Toronto/Description](http://2015.igem.org/Team:Toronto/Description)
* [Team:Toronto/Design](http://2015.igem.org/Team:Toronto/Design)
* [Team:Toronto/Entrepreneurship](http://2015.igem.org/Team:Toronto/Entrepreneurship)
* [Team:Toronto/Experiments](http://2015.igem.org/Team:Toronto/Experiments)
* [Team:Toronto/Measurement](http://2015.igem.org/Team:Toronto/Measurement)
* [Team:Toronto/Modeling](http://2015.igem.org/Team:Toronto/Modeling)
* [Team:Toronto/Notebook](http://2015.igem.org/Team:Toronto/Notebook)
* [Team:Toronto/Part_Collection](http://2015.igem.org/Team:Toronto/Part_Collection)
* [Team:Toronto/Parts](http://2015.igem.org/Team:Toronto/Parts)
* [Team:Toronto/Practices](http://2015.igem.org/Team:Toronto/Practices)
* [Team:Toronto/Results](http://2015.igem.org/Team:Toronto/Results)
* [Team:Toronto/Safety](http://2015.igem.org/Team:Toronto/Safety)
* [Team:Toronto/Software](http://2015.igem.org/Team:Toronto/Software)
* [Team:Toronto/Team](http://2015.igem.org/Team:Toronto/Team)
