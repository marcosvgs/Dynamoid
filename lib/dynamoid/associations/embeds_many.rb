# encoding: utf-8
module Dynamoid #:nodoc:

  # The has_many association.
  module Associations
    class EmbedsMany
      include Association
      include Enumerable

      delegate :first, :last, :empty?, :size, :class, to: :records

      def initialize(*args)
        super
      end

      def declaration_field_name
        "#{name}_embedded"
      end

      def declaration_field_type
        :set
      end

      def find_target
        items = []
        (source.send(source_attribute) || []).each do |item|
          items << target_class.new(self, YAML.load(item))
        end
        items
      end

      def records
        target
      end

      def build(attributes = {})
        item = target_class.new(self, attributes)
        self << item
        item
      end

      def delete(object)
        target unless loaded?
        @target.delete(object) if self.include?(object)
      end

      def <<(object)
        target unless loaded?
        @target << object # unless self.include?(object)
      end

      def each(&block)
        records.each(&block)
      end

      def persist
        source.write_attribute(source_attribute, records.collect(&:persist))
        # source.update_attribute(source_attribute, records.collect(&:persist))
      end

      alias :all :records
      alias :count :size
      alias :nil? :empty?
      alias :remove :delete
      alias :new :build

    end
  end

end
