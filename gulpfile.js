var gulp = require('gulp');
var sass = require('gulp-sass');
var autoprefixer = require('gulp-autoprefixer');

gulp.task('sass', function() {
  gulp.src('./assets/styles/*.scss')
    .pipe(sass())
    .pipe(autoprefixer({
        browsers: ['last 2 versions'],
        cascade: false
    }))
    .pipe(gulp.dest('./lib/hob/assets/css'));
});

gulp.task('js', function() {
  gulp.src('./assets/js/*.js')
    .pipe(gulp.dest('./lib/hob/assets/js'));
});

gulp.task('fonts', function() {
  gulp.src('./assets/fonts/*')
    .pipe(gulp.dest('./lib/hob/assets/fonts'));
});

gulp.task('watch', function() {
  gulp.watch('./assets/styles/**/*.scss', ['sass']);
});
