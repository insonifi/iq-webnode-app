var gulp = require('gulp'),
    browserify = require('browserify'),
    rename = require("gulp-rename"),
    source = require('vinyl-source-stream'),
    watching = false,
    bundlePaths = {
      src: [
          './src/app.coffee'
          //"!client/js/**/lib/**" // Don't bundle libs
      ],
      dest:'./build/'
    }
gulp.task('enable-watch-mode', function() { watching = true });
gulp.task('bundle', function () {
  return browserify(bundlePaths.src)
          .transform('coffee-reactify')
          .bundle()
          .pipe(source('bundle.js'))
          .pipe(rename('app.js'))
          .pipe(gulp.dest(bundlePaths.dest))
});

gulp.task('watch', function() {
  gulp.watch(bundlePaths.src, ['bundle']);
});

gulp.task('default', ['watch', 'bundle']);
