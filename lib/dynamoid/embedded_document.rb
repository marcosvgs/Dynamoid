# encoding: utf-8
module Dynamoid #:nodoc:

  # This is the base module for all domain objects that need to be persisted to
  # the database as documents.
  module EmbeddedDocument
    extend ActiveSupport::Concern
    include Dynamoid::Document

    attr_accessor :parent

    def save
      raise "EmbeddedDocument can't update"
    end

    def initialize(parent, attrs = {})
      @parent = parent
      super(attrs)
      clear_changes_information
    end

    def delete
      @parent.delete(self)
    end

    def persist
      set_created_at
      set_updated_at
      if self.send(self.class.hash_key).blank?
        self.send("#{self.class.hash_key}=", SecureRandom.uuid)
      end
      self.attributes
    end

    alias :remove :delete
    alias :destroy :delete

    private

    def set_updated_at
      if Dynamoid::Config.timestamps && (self.changed? || self.updated_at.blank?)
        self.updated_at = DateTime.now.in_time_zone(Time.zone)
        clear_changes_information
      end
    end

  end
end
