exec = require('shortcake').exec

option '-b', '--browser [browserName]', 'Browser to test with'
option '-s', '--external-selenium',     'Use external selenium'
option '-v', '--verbose',               'Enable verbose logging for tests'

task 'build', 'Build module and bundled checkout.js', ->
  exec 'node_modules/.bin/coffee -bcm -o lib/ src/'
  exec 'node_modules/.bin/requisite src/checkout.coffee -g -o checkout.js'
  exec 'node_modules/.bin/requisite src/checkout.coffee -m -o checkout.min.js'

task 'watch', 'watch for changes and recompile', ->
  exec 'node_modules/.bin/bebop'

task 'deploy', 'deploy new version', ->
  exec [
    'cake build'
    'git commit -am "Updated generated files"'
    'git pull --tags'
    'npm version patch'
    'git push'
    'git push --tags'
  ]

task 'browserstack-tunnel', 'Start tunnel for BrowserStack', (cb) ->
  fs      = require 'fs'
  {spawn} = require 'child_process'

  installTunnel = (cb) ->
    platform = require('os').platform()
    cmds = [
      "wget http://www.browserstack.com/browserstack-local/BrowserStackLocal-#{platform}-x64.zip"
      "unzip BrowserStackLocal-#{platform}-x64.zip"
      "mkdir -p .browserstack"
      "mv BrowserStackLocal .browserstack"
    ]
    exec cmds, cb

  startTunnel = ->
    spawn '.browserstack/BrowserStackLocal', [
          process.env.BROWSERSTACK_KEY
          'localhost,3333,0'
          '-forcelocal'
          '-tunnelIdentifier'
          process.env.TRAVIS_JOB_NUMBER
    ]
    setTimeout cb, 10*1000

  # Download the BrowserStack tunnel helper
  unless fs.existsSync '.browserstack/BrowserStackLocal'
    installTunnel startTunnel
  else
    startTunnel()

task 'static-server', 'Run static server for tests', ->
  connect = require 'connect'
  server = connect()
  server.use (require 'serve-static') './test'

  port = process.env.PORT ? 3333
  console.log "Static server started at http://localhost:#{port}"
  server.listen port

task 'selenium-install', 'Install selenium standalone', ->
  exec 'node_modules/.bin/selenium-standalone install'

task 'test', 'Run tests', (options) ->
  browserName      = options.browser ? 'phantomjs'
  externalSelenium = options.externalSelenium ? false
  verbose          = options.verbose ? false

  runTest = (cb) ->
    exec "NODE_ENV=test
          BROWSER=#{browserName}
          VERBOSE=#{verbose}
          node_modules/.bin/mocha
          --compilers coffee:coffee-script/register
          --reporter spec
          --colors
          --timeout 90000
          test/test.coffee", cb

  invoke 'static-server'

  if externalSelenium
    runTest (err) ->
      process.exit 1 if err?
      process.exit 0
    return

  selenium = require 'selenium-standalone'
  selenium.start (err, child) ->
    throw err if err?

    runTest (err) ->
      child.kill()
      process.exit 1 if err?
      process.exit 0

task 'test-ci', 'Run tests on CI server', (options) ->
  browsers = require './test/ci-config'

  if (browser = options.browser)?
    browsers = (b for b in browsers when b.browserName == browser)

  invoke 'static-server'
  invoke 'browserstack-tunnel', ->
    tests = for {browserName, platform, version, deviceName, deviceOrientation} in browsers
      "BROWSER=\"#{browserName}\"
       PLATFORM=\"#{platform ? ''}\"
       VERSION=\"#{version ? ''}\"
       DEVICE_NAME=\"#{deviceName ? ''}\"
       DEVICE_ORIENTATION=\"#{deviceOrientation ? ''}\"
       node_modules/.bin/mocha
       --compilers coffee:coffee-script/register
       --reporter spec
       --colors
       --timeout 90000
       test/test.coffee"

    process.env.NODE_ENV           = 'test'
    process.env.TRAVIS            ?= 1
    process.env.TRAVIS_JOB_NUMBER ?= 1
    process.env.VERBOSE            = true

    exec tests, (err) ->
      process.exit 1 if err?
