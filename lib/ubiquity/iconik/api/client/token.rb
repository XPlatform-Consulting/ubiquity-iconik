require 'logger'
require 'date'

module Ubiquity
  module Iconik
    module API
      class Client
        class Token

          attr_accessor :client

          attr_reader :attributes, :expiration_date_time

          def initialize(attributes, client = nil)
            attributes = { 'token' => attributes } if attributes.is_a?(String)

            @client = client
            attributes_set(attributes)
          end

          def attributes_need_to_be_populated?
            !expiration?
          end

          def _initialize
            expiration_date_time_set if expiration?
          end

          def attributes_set(_attributes)
            raise ArgumentError, 'Attributes must be a hash' unless _attributes.is_a?(Hash)
            @attributes = _attributes
            _initialize
          end

          def expiration_date_time_set
            expires = attributes['expires']
            @expiration_date_time = expires ? DateTime.parse(expires).new_offset(Rational(0, 24)) : nil
          end

          def expiration?
            @attributes.has_key?('expires')
          end

          def expired?
            @expiration_date_time ? (DateTime.now.new_offset(Rational(0, 24)) > @expiration_date_time) : nil
          end

          def valid?
            (!attributes_need_to_be_populated? && !expired?)
          end

          def populate_attributes
            attributes_set client.auth_token_get :token => @attributes['token']
          end

          def refresh
            attributes_set client.auth_token_refresh
          end

          def to_s; @attributes['token'] end

          # Token
        end

        # Client
      end

      # API
    end

    # Iconik
  end

  # Ubiquity
end
