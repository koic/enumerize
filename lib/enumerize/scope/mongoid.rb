module Enumerize
  module Scope
    module Mongoid
      def enumerize(name, options={})
        super

        _enumerize_module.dependent_eval do
          if self < ::Mongoid::Document
            if options[:scope]
              _define_scope_methods!(name, options)
            end
          end
        end
      end

      private

      def _define_scope_methods!(name, options)
        scope_name = options[:scope] == true ? "with_#{name}" : options[:scope]

        define_singleton_method scope_name do |*values|
          values = values.map { |value| enumerized_attributes[name].find_value(value).value }

          if values.size == 1
            where(name => values.first)
          else
            where(name.in => values)
          end
        end

        if options[:scope] == true
          define_singleton_method "without_#{name}" do |*values|
            values = values.map { |value| enumerized_attributes[name].find_value(value).value }
            not_in(name => values)
          end
        end
      end
    end
  end
end