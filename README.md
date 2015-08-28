# Sequent-Sinatra

[![Build Status](https://travis-ci.org/zilverline/sequent-sinatra.svg?branch=master)](https://travis-ci.org/zilverline/sequent-sinatra) [![Code Climate](https://codeclimate.com/github/zilverline/sequent-sinatra/badges/gpa.svg)](https://codeclimate.com/github/zilverline/sequent-sinatra) [![Test Coverage](https://codeclimate.com/github/zilverline/sequent-sinatra/badges/coverage.svg)](https://codeclimate.com/github/zilverline/sequent-sinatra)

Use the [sequent](https://github.com/zilverline/sequent) gem with the [Sinatra](https://github.com/sinatra/sinatra) web framework.

Provides functionality to initialize sequent and form helpers to bind forms to `Sequent::Core::Command`s.

## Getting started

```sh
gem install sequent-sinatra
```

```ruby
class MyApp < Sinatra::Base
  register Sequent::Web::Sinatra::App
end
```

See [the sample application](https://github.com/zilverline/sequent-examples) for `sequent-sinatra` in action.

## Documentation

### Configuration

`sequent_config_dir` contains the location of `initializers/sequent.rb` file that is uses to initialize sequent.
By default it will use the value `root` configured in your sinatra app.

Example

```ruby
class MyApp < Sinatra::Base
  set :sequent_config_dir, "#{root}/config"
  register Sequent::Web::Sinatra::App
end
```

A minimal example of your `initializers/sequent.rb`

```ruby
Sequent.configure do |config|
 config.event_handlers = [MyEventHandler.new]
 config.command_handlers = [MyCommandHandler.new]
end
```

### Formhelpers

Sequent sinatra provides basic form helpers to bind forms to Commands.

Example:

Given this application

```ruby
class MyApp < Sinatra::Base
  set :sequent_config_dir, "#{root}/config"
  register Sequent::Web::Sinatra::App
  get '/' do
    @command = SignupCommand.new
    erb :index
  end
  post '/' do
    @command = CreateInvoiceCommand.from_params(params[:signup_command])
    execute_command @command do |errors|
          if errors
            erb :index
          else
            redirect '/some-other-page'
          end
    end
  end
end
```

```ruby
class SignupCommand < Sequent::Core::Command
  attrs username: String
  validates_presence_of :username
end
```

You can use the form helpers as follows

```erb
<% html_form_for(@command, "/", :post) do |form| %>
  <% form.fieldset(@command.class.to_s.underscore.to_sym) do |f| %>
    <%= f.raw_input :username, class: "form-input" %>
  <% end %>
  <input type="submit" value="Save">
<% end %>
```

This outputs to the following HTML

```html
<form action="/" method="POST" role="form">
  <input type="hidden" name="_csrf" value="MAF4FQZPM4lssJnB7nyn4UlEssTAQnbVVsMRdfmLcmY=" />
  <input class="form-input" id="signup_command_username" name="signup_command[username]" type="text" />
  <input type="submit" value="Save">
</form>
```

Various for helpers exist

* `raw_input`
* `raw_checkbox`
* `raw_password`
* `raw_textarea`
* `raw_hidden`
* `raw_select`
* `raw_radio`

You can provide the following parameters to these helper methods

* `class` the css class
* `value` default value of the field. This is used when the actual value is `nil`

## Contributing

Fork and send pull requests

## Running the specs

`rspec`

## License

Sequent Sinatra is released under the MIT License
