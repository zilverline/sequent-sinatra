require_relative 'form'
require 'rack/csrf'

module Sequent
  module Web
    module Sinatra
      ##
      # Various form helpers to help bind html forms to `Sequent::Core::Command`s
      #
      module FormHelpers
        ##
        # Creates a form not bound to any Command
        #
        # Parameters
        #   +action+ the action attribute of the <form> tag
        #   +method+ the method attribute of the <form> tag.
        #            :delete and :update will result in an extra hidden field _method to be set so sinatra will call the corresponding `delete '/' {}` or `update `/` {}` methods in your application.
        #   +options+ options hash
        #
        def html_form(action, method=:get, options={}, &block)
          html_form_for nil, action, method, options, &block
        end

        ##
        # Creates a for bound to an object that respond_to :as_params. This is typically a `Sequent::Core::Command` or a `Sequent::Core::ValueObject`.
        #
        # Parameters
        #   +for_object+ The form backing object. This object must `include` Sequent::Core::Helpers::ParamSupport
        #   +action+ the action attribute of the <form> tag
        #   +method+ the method attribute of the <form> tag.
        #            :delete and :update will result in an extra hidden field _method to be set so sinatra will call the corresponding `delete '/' {}` or `update `/` {}` methods in your application.
        #   +options+ options hash
        #
        def html_form_for(for_object, action, method=:get, options={}, &block)
          raise "Given object of class #{for_object.class} does not respond to :as_params. Are you including Sequent::Core::Helpers::ParamSupport?" if (for_object and !for_object.respond_to? :as_params)
          form = Form.new(self, for_object, action, method, options.merge(role: "form"))
          form.render(&block)
        end

        ##
        # Shorthand for Rack::Utils.escape_html(text)
        #
        def h(text)
          Rack::Utils.escape_html(text)
        end

        ##
        # Shorthand for Rack::Csrf.csrf_tag(env)
        #
        def csrf_tag
          raise "You must enable sessions to use FormHelpers" unless env
          Rack::Csrf.csrf_tag(env)
        end

      end
    end
  end
end
