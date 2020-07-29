# Archived

This project's support has been ceased. No future fixes or pull requests are planned.

# Codegrade

## Requirements

CMake is required to build Rugged gem. On Mac you can install it with command:

    brew install cmake

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'codegrade'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install codegrade

## Usage

Run `codegrade` with no arguments to check your last git commit:

    codegrade

Pass commit sha to check this specific commit:

    codegrade 08ffde9e7100f27462cf24259ab89a9ed813a14d

or

    codegrade 08ffde

## Contributing

1. Fork it ( https://github.com/visualitypl/codegrade/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
