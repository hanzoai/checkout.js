webdriver = require 'webdriverio'

exports.getBrowser = ->
  caps =
    browserName:       process.env.BROWSER ? 'phantomjs'
    platform:          process.env.PLATFORM ? 'ANY'
    version:           process.env.VERSION
    deviceName:        process.env.DEVICE_NAME
    deviceOrientation: process.env.DEVICE_ORIENTATION

  logLevel = if process.env.VERBOSE == 'true' then 'verbose' else 'silent'

  opts =
    desiredCapabilities: caps
    logLevel: logLevel

  if process.env.TRAVIS?
    # annotate tests with travis info
    caps.name = process.env.TRAVIS_COMMIT
    caps.tags = [
      process.env.TRAVIS_PULL_REQUEST
      process.env.TRAVIS_BRANCH
      process.env.TRAVIS_BUILD_NUMBER
    ]
    caps['tunnel-identifier'] = process.env.TRAVIS_JOB_NUMBER

  if process.env.SAUCE_CONNECT
    opts =
      desiredCapabilities: caps
      logLevel: logLevel
      host: 'ondemand.saucelabs.com'
      port: 80
      user: process.env.SAUCE_USERNAME
      key: process.env.SAUCE_ACCESS_KEY

  webdriver.remote(opts).init()


TIMEOUT = 5000
if process.env.TRAVIS_CI
  TIMEOUT = TIMEOUT * 10
exports.TIMEOUT = TIMEOUT
