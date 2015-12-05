# Checkout.js  [![Build Status][travis-image]][travis-url] [![Coverage Status][coveralls-image]][coveralls-url] [![NPM version][npm-image]][npm-url]  [![Gitter chat][gitter-image]][gitter-url]
Our checkout widget makes it possible to start taking pre-orders in minutes,
and is quite customizable.

## Preview
![Screenshot Preview](examples/basic/basic_screenshot.png)

## Install
```bash
$ npm install checkout.js
```

## Usage
Set the `href` of your button to `#checkout`.

```html
<a class="btn" href="#checkout">Buy Now</a>
```

Configure the checkout widget however you'd like.

```javascript
<script src="https://cdn.rawgit.com/crowdstart/checkout.js/v2.1.2/checkout.min.js"></script>
<script>
  // Create a new client for Crowdstart API.
  var api = new Crowdstart.API('eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJiaXQiOjI0LCJqdGkiOiJVMDc0RlU3MHVhWSIsInN1YiI6IkVxVEdveHA1dTMifQ.g_MqPv2s0DnyFdhkUMzYn9mtKaXNwmlEM14WcFq_s5Yd2eqH16TB9thxOdDE8ylcoBMgyI3eimSHJxGq7oj-EA')

  // Create default order, should match whatever the user is trying to pre-order
  var order = new Crowdstart.Order('usd',[
    new Crowdstart.ItemRef('84cRXBYs9jX7w', -1),
    new Crowdstart.ItemRef('doge-shirt', 100)
  ]);

  // Create default user (pre-populated in form fields)
  var user = new Crowdstart.User('joe@fan.com', 'Joe', 'Fan')

  // Social sharing settings
  var config = {
    facebook:   'suchtees',
    googlePlus: 'suchtees',
    twitter:    'suchtees',
  }

  // Customize theme
  Crowdstart.setTheme({
    borderRadius: 5,
  })

  // Instantiate widget, can be called multiple times, overriding order in widget.
  Crowdstart.Checkout('checkout', api, order, user, config);
</script>
```

## Examples
You can find examples in [examples/](examples/basic/index.html). You can also
see it in action in the [Crowdstart
documentation](http://www.crowdstart.com/docs/checkout).

## Testing
To test locally, [phantomjs2](https://www.npmjs.com/package/phantomjs2) must be installed.

[crowdstart]: https://crowdstart.com
[checkout.js]: https://cdn.rawgit.com/crowdstart/checkout.js/v2.1.2/checkout.min.js
[travis-url]: https://travis-ci.org/crowdstart/checkout.js
[travis-image]: https://img.shields.io/travis/crowdstart/checkout.js.svg
[coveralls-url]: https://coveralls.io/r/crowdstart/checkout.js/
[coveralls-image]: https://img.shields.io/coveralls/crowdstart/checkout.js.svg
[npm-url]: https://www.npmjs.com/package/checkout.js
[npm-image]: https://img.shields.io/npm/v/checkout.js.svg
[downloads-image]: https://img.shields.io/npm/dm/checkout.js.svg
[downloads-url]: http://badge.fury.io/js/checkout.js
[gitter-url]: https://gitter.im/crowdstart/chat
[gitter-image]: https://img.shields.io/badge/gitter-chat-brightgreen.svg
