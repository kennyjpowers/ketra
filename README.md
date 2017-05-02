# Ketra

## Description

The Ketra gem provides a friendly Ruby interface to the Ketra API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ketra'
```

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
Ketra.authorization_grant = :password
credentials = { username: 'YOUR DESIGN STUDIO USERNAME', password: 'YOUR DESIGN STUDIO PASSWORD' }
Ketra.authorize(credentials)
access_token = Ketra.access_token
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kennyjpowers/ketra. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

