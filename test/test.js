var selenium = require('selenium-standalone');
var webdriver = require('webdriverio');
var assert = require('assert');
var static = require('node-static');
var http = require('http');

var currentPort = 9000;

function run(seleniumParams) {
  describe('['+ seleniumParams.desiredCapabilities.browserName + '] Checkout widget', function() {
    this.timeout(0);
    var staticServer = null;
    var server = null;
    var client = null;
    var port = currentPort + Math.floor(Math.random() * (1000-1+1)+1);

    before(function(done) {
      staticServer = new static.Server('./test')
      server = http.createServer(function(req, res) {
        req.addListener('end', function() {
          staticServer.serve(req, res);
        }).resume();
      }).listen(port);

      selenium.start(function(err, child) {
        if (err) throw err;
        selenium.proc = child;
        client = webdriver.remote(seleniumParams).init(function() {
          done();
        });
      });
    });

    function sleep(seconds) {
      var e = new Date().getTime() + (seconds * 1000);
      while (new Date().getTime() <= e) {}
    }

    describe('Changing the quantity of a line item', function() {
      it("should update line item cost", function(done) {
        var unitPrice = 0;
        function parsePrice(str) {
          str = str.substring(1, str.length); // strip $
          return parseFloat(str);
        }

        client.url('http://localhost:' + port  + '/widget.html', function() {
            sleep(3);
          })

          // Click the Buy button
          .click('a.btn', function() {
            sleep(3);
          })

          // Select 2 for 'Such T-shirt'
          .click('/html/body/modal/div[1]/checkout/div/div[3]/div[2]/div[2]/div[1]/div[1]/span/span[1]/span', function() {
          })
          .click('/html/body/span/span/span[2]/ul/li[3]', function() {
          })

          .getText('body > modal > div.crowdstart-modal-target > checkout > div > div.crowdstart-forms > div.crowdstart-invoice > div:nth-child(2) > div:nth-child(2) > div:nth-child(2) > span', function(err, res) {
            unitPrice = parsePrice(res);
          })
          .getText('body > modal > div.crowdstart-modal-target > checkout > div > div.crowdstart-forms > div.crowdstart-invoice > div:nth-child(2) > div:nth-child(2) > div.crowdstart-col-1-3-bl.crowdstart-text-right.crowdstart-money', function(err, res) {
            lineItemPrice = parsePrice(res);
            assert.strictEqual(lineItemPrice, unitPrice * 2);
          })
          .call(done);
      });
    });

    describe('Completing the form', function() {
      it('should work', function(done) {
        client
          .setValue('#crowdstart-credit-card', '4242424242424242', function() {
          })
          .setValue('#crowdstart-expiry', '1122', function() {
          })
          .setValue('#crowdstart-cvc', '424', function() {
          })
          .click('span.crowdstart-checkbox', function() {
          })
          .click('a.crowdstart-checkout-button', function() {
            // next
            sleep(1);
          })

          .setValue('#crowdstart-line1', '1234 fake street', function() {
          })
          .setValue('#crowdstart-city', 'fake city', function() {
          })
          .setValue('#crowdstart-state', 'fake state', function() {
          })
          .setValue('#crowdstart-postalCode', '55555', function() {
          })

          .click('a.crowdstart-checkout-button', function() {
          })

          .waitForVisible('body > modal > div.crowdstart-modal-target > checkout > div > div.crowdstart-forms > div.crowdstart-screens > div > div > form > h1', 20000, false, function() {
            client.getText('body > modal > div.crowdstart-modal-target > checkout > div > div.crowdstart-forms > div.crowdstart-screens > div > div > form > h1', function(err, res) {
              assert.strictEqual(res, 'Thank You');
            })
          })
          .call(done);
      })
    })

    after(function(done) {
      client.end(function() {
        server.close();
        selenium.proc.kill();
        done();
      });
    });
  });
}

if (Boolean(process.env.CI) && Boolean(process.env.TRAVIS)) {
  var browsers = [
    'firefox'
    , 'chrome'
    // , 'opera'
  ];
  browsers.forEach(function(browser) {
    run({
      desiredCapabilities: {
        browserName: browser,
        name: process.env.TRAVIS_COMMIT,
        tags: [
               process.env.TRAVIS_PULL_REQUEST,
               process.env.TRAVIS_BRANCH,
               process.env.TRAVIS_BUILD_NUMBER
              ],
        'tunnel-identifier': process.env.TRAVIS_JOB_NUMBER
      },
      host: 'ondemand.saucelabs.com',
      port: 80,
      user: process.env.SAUCE_USERNAME,
      key: process.env.SAUCE_ACCESS_KEY,
      logLevel: 'silent'
    })
  });
} else {
  run({
    desiredCapabilities: {
      browserName: 'firefox'
    }
  })
}
