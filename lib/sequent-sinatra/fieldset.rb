require_relative 'tag_helper'
require_relative 'fieldset'

module Sequent
  module Web
    module Sinatra
      class Fieldset
        include Sequent::Web::Sinatra::TagHelper

        attr_reader :path, :parent

        def postfix
          nil
        end

        def initialize(parent, path, params, errors, options = {})
          raise "params are empty while creating new fieldset path #{path}" unless params
          @values = params[path] || {}
          @parent = parent
          @path = path.to_s.gsub(/\W+/, '')
          @errors = errors
          @options = options
        end

        def nested_array(name)
          (@values[name] || [{}]).each do |value|
            yield FieldsetInArray.new(self, name, { name => value }, @errors, @options)
          end
        end

        def nested(name)
          yield Fieldset.new(self, name, @values, @errors, @options)
        end

        def method_missing(method, *args, &block)
          @parent.send(method, *args)
        end

        def path_for(field_name)
          css_id @path, field_name
        end
      end

      class FieldsetInArray < Fieldset
        def postfix
          "[]"
        end
      end
    end
  end
end
