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

  invoke 'static-server'

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

  if externalSelenium
    runTest (err) ->
      process.exit 1 if err?
      process.exit 0

  selenium = require 'selenium-standalone'
  selenium.start (err, child) ->
    throw err if err?

    runTest (err) ->
      child.kill()
      process.exit 1 if err?
      process.exit 0

task 'test-ci', 'Run tests on CI server', ->
  invoke 'static-server'

  BrowserStackTunnel = require 'browserstacktunnel-wrapper'
  bst = new BrowserStackTunnel
    key: process.env.BS_AUTHKEY
    hosts: [{
      name: 'localhost'
      port: 3333
      sslFlag: 0
    }]
    v: true # verbose
  #   osxBin: 'your_bin_dir'
  #   linux32Bin: 'your_bin_dir'
  #   linux64Bin: 'your_bin_dir'
  #   win32Bin: 'your_bin_dir'
  #   localIdentifier: 'my_tunnel'
  #   proxyUser: PROXY_USER
  #   proxyPass: PROXY_PASS
  #   proxyPort: PROXY_PORT
  #   proxyHost: PROXY_HOST
  #   force: false
  #   forcelocal: false
  #   onlyAutomate: false

  bst.start (err) ->
    console.log err if err?

  browsers = require './test/ci-config'

  tests = for {browserName, platform, version, deviceName, deviceOrientation} in browsers
    "NODE_ENV=test
     BROWSER=\"#{browserName}\"
     PLATFORM=\"#{platform}\"
     VERSION=\"#{version}\"
     DEVICE_NAME=\"#{deviceName ? ''}\"
     DEVICE_ORIENTATION=\"#{deviceOrientation ? ''}\"
     VERBOSE=true
     node_modules/.bin/mocha
     --compilers coffee:coffee-script/register
     --reporter spec
     --colors
     --timeout 60000
     test/test.coffee"

  exec tests, (err) ->
    process.exit 1 if err?
    process.exit 0

  bst.stop (err) ->
    console.log err if err?
