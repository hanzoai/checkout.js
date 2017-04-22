# Checkout.js

[![npm][npm-img]][npm-url]
[![build][build-img]][build-url]
[![dependencies][dependencies-img]][dependencies-url]
[![downloads][downloads-img]][downloads-url]
[![license][license-img]][license-url]
[![chat][chat-img]][chat-url]

> Easy to use checkout powered by [Hanzo][hanzo]

Checkout.js is an easy to use checkout widget powered by [Hanzo][hanzo]. It
makes it possible for businesses to begin taking pre-orders in minutes.

## Preview
![Checkout.js Image][checkout-image]

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
<script src="https://cdn.rawgit.com/hanzo-io/checkout.js/v2.1.21/checkout.min.js"></script>
<script>
  var {Checkout, User, Order, Product} = Hanzo

  // Create user (pre-populated in form fields)
  var user = new User({
    email:     'joe@fan.com',
    firstName: 'Joe',
    lastName:  'Fan'
  })

  // Create order
  var order = new Order({
    currency: 'usd',
    items: [
      new Product({id:   '84cRXBYs9jX7w', quantity: 1}),
      new Product({slug: 'doge-shirt',    quantity: 1}),
    ]
  })

  // Instantiate checkout widget.
  var checkout = new Checkout('your access token', {
    social: {
      facebook:   'suchtees',
      googlePlus: 'suchtees',
      twitter:    'suchtees',
  })

  // Open widget. This can be called multiple times, overriding order or user.
  checkout.open('#checkout', user, order)
</script>
```

## Examples
You can find more examples [here][examples].

## License
[BSD][license-url]

[checkout-image]:  https://cdn.rawgit.com/hanzo-io/checkout.js/v2.1.21/examples/basic/basic_screenshot.png
[checkout.js]:     https://cdn.rawgit.com/hanzo-io/checkout.js/v2.1.21/checkout.min.js
[hanzo]:           https://hanzo.io
[examples]:        https://github.com/hanzo-io/checkout.js/tree/master/examples

[build-img]:        https://img.shields.io/travis/hanzo-io/hanzo.js.svg
[build-url]:        https://travis-ci.org/hanzo-io/hanzo.js
[chat-img]:         https://badges.gitter.im/join-chat.svg
[chat-url]:         https://gitter.im/hanzo-io/chat
[coverage-img]:     https://coveralls.io/repos/hanzo-io/hanzo.js/badge.svg?branch=master&service=github
[coverage-url]:     https://coveralls.io/github/hanzo-io/hanzo.js?branch=master
[dependencies-img]: https://david-dm.org/hanzo-io/hanzo.js.svg
[dependencies-url]: https://david-dm.org/hanzo-io/hanzo.js
[downloads-img]:    https://img.shields.io/npm/dm/hanzo.js.svg
[downloads-url]:    http://badge.fury.io/js/hanzo.js
[license-img]:      https://img.shields.io/npm/l/hanzo.js.svg
[license-url]:      https://github.com/hanzo-io/hanzo.js/blob/master/LICENSE
[npm-img]:          https://img.shields.io/npm/v/hanzo.js.svg
[npm-url]:          https://www.npmjs.com/package/hanzo.js
