Sequent.configure do |config|
  config.command_service = Sequent::Core::CommandService.new(self)
end
