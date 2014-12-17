# BootswatchSass

A SASS/Sprockets version of the [Bootswatch themes](http://bootswatch.com/).

## Installation

Add this line to your application's Gemfile:

``` ruby
gem 'bootswatch-sass', '~> 3.3.0'
```

And then execute:

``` bash
bundle
```

Or install it yourself as:

``` bash
gem install bootswatch-sass
```

## Usage

In this example we'll use the `Cyborg` theme.
If you want the default theme, replace `bootstrap-cyborg` with `bootstrap`.
In your `application.js` add:

``` javascript
//= require bootstrap
```

In your `application.css` add:

``` css
@import "bootstrap-cyborg";
```

That's it.

## Contributing

1. [Fork it](https://github.com/tzvetkoff/bootswatch-sass/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new pull request
