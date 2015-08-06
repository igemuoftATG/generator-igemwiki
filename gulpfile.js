var gulp = require('gulp');
var handlebars = require('gulp-compile-handlebars');
var rename = require('gulp-rename');
var fs = require('fs');

var paths = {
    partials: './src/partials'
}

var hbsOptions = {
    batch : [paths.partials],
    helpers : {
        capitals : function(str){
            return str.toUpperCase();
        }
    }
}

templateDataDev = JSON.parse(fs.readFileSync('./src/templates/template-dev.json'))

gulp.task('handlebars', function() {
    return gulp.src('src/hello.hbs')
        .pipe(handlebars(templateDataDev, hbsOptions))
        .pipe(rename('hello.html'))
        .pipe(gulp.dest('build-dev'));
})

gulp.task('default', ['handlebars']);
