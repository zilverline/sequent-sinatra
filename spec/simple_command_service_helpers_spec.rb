require 'spec_helper'

describe Sequent::Web::Sinatra::SimpleCommandServiceHelpers do
  class MockForSimpleCommandServiceHelpers
    def initialize
      @command_service = Module.new do
        def self.execute_commands(command)
          command.execute
        end
      end
    end
    include Sequent::Web::Sinatra::SimpleCommandServiceHelpers
  end

  let(:app) do
    MockForSimpleCommandServiceHelpers.new
  end

  let(:failing_command) do
    double('command').tap do |command|
      allow(command).to receive(:execute).and_raise(Sequent::Core::CommandNotValid.new(double('command', validation_errors: :foo)))
    end
  end

  let(:passing_command) do
    double('command', execute: true)
  end

  describe '#execute_command' do
    it 'yields with no arguments if command successful' do
      errors = nil
      app.execute_command(failing_command) do |_errors|
        errors = _errors
      end
      expect(errors).to_not be_nil
    end

    it 'yields with errors if command unsuccessful' do
      errors = nil
      app.execute_command(passing_command) do |_errors|
        errors = _errors
      end
      expect(errors).to be_nil
    end
  end
end
