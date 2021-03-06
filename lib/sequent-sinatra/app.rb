require 'sinatra'
module Sequent
  module Web
    module Sinatra
      # Allows for easy integration with Sinatra apps.
      # Provides:
      #
      #   +Sequent::Core::Helpers::UuidHelper+
      #   +FormHelpers+
      #   +SimpleCommandServiceHelpers+
      #
      # The +sequent_config_dir+ allows you to specify the directory containing the
      # 'initializers/sequent' file that initializes the +EventStore+ and +CommandService+ for your webapp.
      #
      # class MySinatraApp < Sinatra::Base
      #   set :sequent_config_dir, root
      #   register Sequent::Web::Sinatra::App
      # end
      module App
        def self.registered(app)
          app.helpers Sequent::Core::Helpers::UuidHelper
          app.helpers Sequent::Web::Sinatra::FormHelpers
          app.helpers Sequent::Web::Sinatra::SimpleCommandServiceHelpers
          app.set :sequent_config_dir, app.root unless app.respond_to?(:sequent_config_dir)

          app.before do
            config_file = File.join(app.sequent_config_dir, 'initializers/sequent')
            if File.exist?("#{config_file}.rb") || File.exist?("#{config_file}")
              require config_file
            else
              raise "Unable to initialize Sequent. Config file #{config_file} not found.\nInitialize Sequent correctly? First set the 'sequent_config_dir' or the 'root', then register Sequent::Web::Sinatra in your Sinatra application"
            end
            @command_service = Sequent.command_service
          end

        end
      end
    end
  end
end
Sinatra.register Sequent::Web::Sinatra::App
