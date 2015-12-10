require 'shortcake'

use 'cake-version'
use 'cake-publish'

fs        = require 'fs'
requisite = require 'requisite'

option '-b', '--browser [browser]', 'browser to use for tests'
option '-g', '--grep [filter]',     'test filter'
option '-t', '--test [test]',       'specify test to run'
option '-v', '--verbose',           'enable verbose test logging'

task 'build', 'Build module and bundled checkout.js', ->
  exec.parallel '''
    coffee -bcm -o lib/ src/'
    bebop -c'
  '''

task 'clean', 'clean project', ->
  exec 'rm -rf lib'

task 'build-min', 'build project', ['build'], ->
  exec 'uglifyjs checkout.js --compress --mangle --lint=false > checkout.min.js'

server = do require 'connect'

task 'static-server', 'Run static server for tests', (cb) ->
  port = process.env.PORT ? 3333

  server.use (require 'serve-static') './test/fixtures'
  server = require('http').createServer(server).listen port, cb

task 'test', 'Run tests', ['static-server'], (opts) ->
  bail     = opts.bail     ? true
  coverage = opts.coverage ? false
  grep     = opts.grep     ? ''
  test     = opts.test     ? 'test/'

  verbose  = opts.verbose  ? ''

  bail    = '--bail' if bail
  grep    = "--grep #{opts.grep}" if grep
  verbose = 'DEBUG=nightmare VERBOSE=true' if verbose

  if coverage
    bin = 'istanbul --print=none cover _mocha --'
  else
    bin = 'mocha'

  {status} = yield exec.interactive "NODE_ENV=test #{verbose}
        #{bin}
        --colors
        --reporter spec
        --timeout 10000000
        --compilers coffee:coffee-script/register
        --require co-mocha
        --require postmortem/register
        #{bail}
        #{grep}
        #{test}"

  server.close()
  process.exit status

task 'test-ci', 'Run tests', (opts) ->
  invoke 'test', bail: true, coverage: true

task 'coverage', 'Process coverage statistics', ->
  exec '''
    cat ./coverage/lcov.info | coveralls
    cat ./coverage/coverage.json | codecov
    rm -rf coverage/
    '''

task 'watch', 'watch for changes and recompile project', ->
  exec 'coffee -bcmw -o lib/ src/'
  exec 'bebop -o'

task 'watch:test', 'watch for changes and re-run tests', ->
  invoke 'watch'

  require('vigil').watch __dirname, (filename, stats) ->
    if /^src/.test filename
      invoke 'test'

    if /^test/.test filename
      invoke 'test', test: filename
