fs        = require 'fs'
path      = require 'path'
exec      = require('executive').interactive
requisite = require 'requisite'

compileJade = (opts, cb) ->
  jade = require 'jade'

  fn = jade.compile opts.source,
    compileDebug: false
    debug: false
    filename: opts.filename

  cb null, """
  module.exports = #{JSON.stringify fn()}
  """

compileCoffee = (src) ->
  return unless /^src|^templates|src\/index.coffee$/.test src

  requisite.bundle
    entry: 'src/index.coffee'
    globalRequire: true
    compilers:
      jade: compileJade
  , (err, bundle) ->
    return console.error err if err?
    fs.writeFileSync 'checkout.js', bundle.toString(), 'utf8'
    console.log 'compiled checkout.js'

module.exports =
  port: 4242

  cwd: process.cwd()

  exclude: [
    /lib/
    /node_modules/
    /vendor/
  ]

  compilers:
    css: -> false
    coffee: compileCoffee
    jade:   compileCoffee

    styl: (src, dst) ->
      return unless /^css|css\/checkout.styl$/.test src

      CleanCSS     = require 'clean-css'
      autoprefixer = require 'autoprefixer'
      comments     = require 'postcss-discard-comments'
      lost         = require 'lost-stylus'
      postcss      = require 'poststylus'
      rupture      = require 'rupture'
      stylus       = require 'stylus'

      src = 'css/checkout.styl'
      dst = 'checkout.css'

      style = stylus fs.readFileSync src, 'utf8'
        .set 'filename', src
        .set 'include css', true
        .set 'sourcemap',
          basePath: ''
          sourceRoot: '../'
        .use lost()
        .use rupture()
        .use postcss [
          autoprefixer browsers: '> 1%'
          'lost'
          'rucksack-css'
          'css-mqpacker'
          comments removeAll: true
        ]

      style.render (err, css) ->
        return console.error err if err

        sourceMapURL = (path.basename dst) + '.map'

        # compile with source maps for development
        unless process.env.PRODUCTION
          css = css + "/*# sourceMappingURL=#{sourceMapURL} */"

          fs.writeFileSync dst, css, 'utf8'
          fs.writeFileSync dst + '.map', JSON.stringify style.sourcemap, 'utf8'
          console.log 'compiled ' + dst
          return

        # compile minified version for production
        minified = new CleanCSS
          semanticMerging: true
        .minify css

        dst = dst.replace /\.js$/.min.js/

        fs.writeFileSync dst, minified.styles, 'utf8'
