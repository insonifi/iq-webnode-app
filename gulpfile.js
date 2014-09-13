var gulp = require('gulp'),
    browserify = require('gulp-browserify'),
    rename = require("gulp-rename");

// Basic usage
gulp.task('default', function() {
  // Single entry point to browserify
  gulp.src('src/app.coffee', {read: false})
    .pipe(browserify({
      transform: ['coffeeify', 'reactify'],
      extensions: ['.coffee'],
      debug: true
    }))
    .pipe(rename('app.js'))
    .pipe(gulp.dest('./build'))
});

