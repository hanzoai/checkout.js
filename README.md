# checkout.js  [![Build Status][travis-image]][travis-url] [![Coverage Status][coveralls-image]][coveralls-url] [![NPM version][npm-image]][npm-url]  [![Gitter chat][gitter-image]][gitter-url] [![Greenkeeper badge](https://badges.greenkeeper.io/hanzo-io/checkout.js.svg)](https://greenkeeper.io/)
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

[checkout-image]:  https://cdn.rawgit.com/hanzo-io/checkout.js/v2.1.21/examples/basic/basic_screenshot.png
[checkout.js]:     https://cdn.rawgit.com/hanzo-io/checkout.js/v2.1.21/checkout.min.js
[hanzo]:           https://hanzo.io
[examples]:        https://github.com/hanzo-io/checkout.js/tree/master/examples

[coveralls-image]: https://img.shields.io/coveralls/hanzo-io/checkout.js.svg
[coveralls-url]:   https://coveralls.io/r/hanzo-io/checkout.js/
[downloads-image]: https://img.shields.io/npm/dm/checkout.js.svg
[downloads-url]:   http://badge.fury.io/js/checkout.js
[gitter-image]:    https://img.shields.io/badge/gitter-join_chat-brightgreen.svg
[gitter-url]:      https://gitter.im/hanzo-io/chat
[npm-image]:       https://img.shields.io/npm/v/checkout.js.svg
[npm-url]:         https://www.npmjs.com/package/checkout.js
[travis-image]:    https://img.shields.io/travis/hanzo-io/checkout.js.svg
[travis-url]:      https://travis-ci.org/hanzo-io/checkout.js
