module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js',
    './config/initializers/heroicon.rb',
    './node_modules/flowbite/**/*.js'
  ],
  plugins: [
    require('@tailwindcss/forms'),
    require('flowbite/plugin')
  ]
}
