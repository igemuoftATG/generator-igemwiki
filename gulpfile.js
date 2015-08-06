var gulp = require('gulp');
var handlebars = require('gulp-compile-handlebars');
var rename = require('gulp-rename');

gulp.task('default', function () {
    var templateData = {
        firstName: 'iGEM Toronto'
    },
    options = {
        ignorePartials: true, //ignores the unknown footer2 partial in the handlebars template, defaults to false
        partials : {
            footer : '<footer>the end</footer>'
        },
        batch : ['./src/partials'],
        helpers : {
            capitals : function(str){
                return str.toUpperCase();
            }
        }
    }

    return gulp.src('src/hello.hbs')
        .pipe(handlebars(templateData, options))
        .pipe(rename('hello.html'))
        .pipe(gulp.dest('build-dev'));
});
