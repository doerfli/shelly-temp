// postcss.config.js
module.exports = {
  plugins: [
    require('postcss-import'),
    require('postcss-nesting'),
    require('@tailwindcss/postcss'),
    require('autoprefixer'),
  ]
}
