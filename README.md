# Sequent-Sinatra

[![Build Status](https://travis-ci.org/zilverline/sequent-sinatra.svg?branch=master)](https://travis-ci.org/zilverline/sequent-sinatra) [![Code Climate](https://codeclimate.com/github/zilverline/sequent-sinatra/badges/gpa.svg)](https://codeclimate.com/github/zilverline/sequent-sinatra) [![Test Coverage](https://codeclimate.com/github/zilverline/sequent-sinatra/badges/coverage.svg)](https://codeclimate.com/github/zilverline/sequent-sinatra)

## Getting started

```
gem install sequent-sinatra
```

```
class MySinatraApp < Sinatra::Base
  set :sequent_config_dir, root
  register Sequent::Web::Sinatra::App
end
```

[See the sample application for further details](https://github.com/zilverline/sequent-examples)
