module Sequent
  module Web
    module Sinatra
      module SimpleCommandServiceHelpers
        #
        # execute a single command. Since it is default for most cases a CommandNotValid exception is handled in this method.
        #
        # Example usage:
        #
        #   post '/foo' do
        #     @command = FooCommand.from_params(params)
        #     execute_command(@command, :erb_name)
        #   end
        def execute_command(command)
          @command_service.execute_commands(command)
          yield if block_given?
        rescue Sequent::Core::CommandNotValid => e
          yield e.errors_with_command_prefix if block_given?
        end
      end
    end
  end
end
