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
