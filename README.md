# Ketra

[![Gem Version](https://badge.fury.io/rb/ketra.png)](https://badge.fury.io/rb/ketra)
[![Build Status](https://travis-ci.org/kennyjpowers/ketra.svg?branch=master)](https://travis-ci.org/kennyjpowers/ketra)
[![Coverage Status](https://coveralls.io/repos/github/kennyjpowers/ketra/badge.svg?branch=master)](https://coveralls.io/github/kennyjpowers/ketra?branch=master)

## Description

The Ketra gem provides a friendly Ruby interface to the Ketra API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ketra'
```

NOTE: versions 0.3.0+ are only supported for use with Ketra N4 Hubs with 1.15+ firmware

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ketra

## Usage

In order to use this gem you will need to contact Ketra Support and get assigned a client_id and client_secret

### Authentication

#### Password grant

```ruby
require 'ketra'
Ketra.client_id = 'YOUR CLIENT ID'
Ketra.client_secret = 'YOUR CLIENT SECRET'
Ketra.client.authorize(:username => 'YOUR DESIGN STUDIO USERNAME', :password => 'YOUR DESIGN STUDIO PASSWORD)
access_token = Ketra.client.access_token
```

#### Set Access Token Directly

```ruby
Ketra.client.authorize(:token => 'YOUR ACCESS TOKEN')
```

### Remote API Configuration
```ruby
Ketra.client.options[:api_mode] = :remote
Ketra.client.options[:installation_id] = 'YOUR INSTALLATION ID'
Ketra.client.options[:hub_serial] = 'YOUR HUB SERIAL NUMBER'
```

### Local API Configuration 
```ruby
Ketra.client.options[:api_mode] = :local #optional since :local is the default
Ketra.client.options[:hub_serial] = 'YOUR HUB SERIAL NUMBER'
```

### Commands

All commands require authentication and the correct configuration for either remote or local API mode.

#### Keypad Buttons

```ruby
Ketra::Commands.activate_button('YOUR KEYPAD NAME', 'YOUR BUTTON NAME')
Ketra::Commands.deactivate_button('YOUR KEYPAD NAME', 'YOUR BUTTON NAME')
Ketra::Commands.push_button('YOUR KEYPAD NAME', 'YOUR BUTTON NAME')
```

#### Queries

```ruby
Ketra::Commands.keypads
Ketra::Commands.groups
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kennyjpowers/ketra. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

