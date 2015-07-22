webdriver = require 'webdriverio'

exports.getBrowser = ->
  caps =
    browserName:       process.env.BROWSER ? 'phantomjs'
    platform:          process.env.PLATFORM
    version:           process.env.VERSION
    deviceName:        process.env.DEVICE_NAME
    deviceOrientation: process.env.DEVICE_ORIENTATION

  opts =
    desiredCapabilities: caps
    logLevel: 'verbose'

  if process.env.TRAVIS?
    # annotate tests with travis info
    caps.name = process.env.TRAVIS_COMMIT
    caps.tags = [
      process.env.TRAVIS_PULL_REQUEST
      process.env.TRAVIS_BRANCH
      process.env.TRAVIS_BUILD_NUMBER
    ]
    caps['tunnel-identifier'] = process.env.TRAVIS_JOB_NUMBER

    opts =
      desiredCapabilities: caps
      logLevel: 'verbose'
      host: 'ondemand.saucelabs.com'
      port: 80
      user: process.env.SAUCE_USERNAME
      key: process.env.SAUCE_ACCESS_KEY

  webdriver.remote(opts).init()
