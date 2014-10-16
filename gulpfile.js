var gulp = require('gulp'),
    browserify = require('gulp-browserify'),
    react = require('gulp-react'),
    rename = require("gulp-rename"),
    watching = false,
    bundlePaths = {
      src: [
          'src/app.coffee'
          //"!client/js/**/lib/**" // Don't bundle libs
      ],
      dest:'build/'
    }
gulp.task('enable-watch-mode', function() { watching = true });
// Basic usage
gulp.task('default', function() {
  // Single entry point to browserify
  gulp.src(bundlePaths.src, {read: false})
    .pipe(browserify({
      transform: ['coffee-reactify'],
      extensions: ['.coffee'],
      debug: true
    }))
    .pipe(react())
    .pipe(rename('app.js'))
    .pipe(gulp.dest(bundlePaths.dest))
});
