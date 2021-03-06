module ActiveRemote
  module Integration
    extend ActiveSupport::Concern

    included do
      unless singleton_methods.include?(:cache_timestamp_format)
        ##
        # :singleton-method:
        # Indicates the format used to generate the timestamp format in the cache key.
        # This is +:number+, by default.
        #
        def self.cache_timestamp_format
          :number
        end
      end
    end

    ##
    # Returns a String, which can be used for constructing an URL to this
    # object. The default implementation returns this record's guid as a String,
    # or nil if this record's unsaved.
    #
    #   user = User.search(:name => 'Phusion')
    #   user.to_param  # => "GUID-1"
    #
    def to_param
      self[:guid] && self[:guid].to_s
    end

    ##
    # Returns a cache key that can be used to identify this record.
    #
    # ==== Examples
    #
    #   Product.new.cache_key     # => "products/new"
    #   Person.search(:guid => "derp-5").cache_key  # => "people/derp-5-20071224150000" (include updated_at)
    #   Product.search(:guid => "derp-5").cache_key # => "products/derp-5"
    #
    def cache_key
      case
      when new_record? then
        "#{self.class.name.underscore}/new"
      when ::ActiveRemote.config.default_cache_key_updated_at? && (timestamp = self[:updated_at]) then
        timestamp = timestamp.utc.to_s(self.class.cache_timestamp_format)
        "#{self.class.name.underscore}/#{self.to_param}-#{timestamp}"
      else
        "#{self.class.name.underscore}/#{self.to_param}"
      end
    end
  end
end
