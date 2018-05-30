require 'logger'
require 'date'
require 'yaml'

require 'ubiquity/iconik/api/client/http_client'
require 'ubiquity/iconik/api/client/requests'
require 'ubiquity/iconik/api/client/paginator'

module  Ubiquity
  module Iconik
    module API
      class Client

        attr_accessor :http_client, :request, :response, :logger

        def initialize(args = { })
          @http_client = HTTPClient.new(args)
          @logger = http_client.logger

        end

        # Exposes HTTP Methods
        # @example http(:get, '/')
        def http(method, *args)
          @request = nil
          @response = http_client.send(method, *args)
          @request = http_client.request
          response
        end

        def paginator
          @paginator ||= Paginator.new(self) if @response
        end

        def process_request(request, options = nil)
          @paginator = nil
          @response = nil
          @request = request

          logger.warn { "Request is Missing Required Arguments: #{request.missing_required_arguments.inspect}" } unless request.missing_required_arguments.empty?

          if ([:all, 'all'].include?(request.arguments[:page]))
            request.arguments[:page] = 1
            include_remaining_pages = true
          else
            include_remaining_pages = false
          end

          request.client = self unless request.client
          options ||= request.options
          logger.warn { "Request is Missing Required Arguments: #{request.missing_required_arguments.inspect}" } unless request.missing_required_arguments.empty?

          return (options.fetch(:return_request, true) ? request : nil) unless options.fetch(:execute_request, true)

          #@response = http_client.call_method(request.http_method, { :path => request.path, :query => request.query, :body => request.body }, options)
          @response = request.execute

          if include_remaining_pages
            return paginator.include_remaining_pages
          end

          @response
        end

        def process_request_using_class(request_class, args, options = { })
          @response = nil
          @request = request_class.new(args, options.merge(:client => self))
          process_request(request, options)
        end

        # Tries to determine if the last request got a successful response
        def success?
          return unless @request
          if @request.respond_to?(:success?)
            @request.success?
          else
            _response = http_client.response
            _response && _response.code.start_with?('2')
          end
        rescue => e
          logger.error { "Exception executing method :success?. '#{e.message}'\n#{e.backtrace}" }
          return false
        end

        # def success?
        #   request && (request.respond_to?(:success?) ? request.success? : (response && response.code.start_with?('2')))
        # end

        # Will try to return the most concise error message possible
        #
        # Example:
        # {
        #   "invalidInput": {
        #       "id": "portal_mf734147",
        #       "context": "metadata-field",
        #       "value": null,
        #   "explanation": "The metadata value is invalid"
        #   },
        #   "conflict": null,
        #   "notAuthorized": null,
        #   "fileAlreadyExists": null,
        #   "licenseFault": null,
        #   "notFound": null,
        #   "internalServer": null,
        #   "forbidden": null,
        #   "notYetImplemented": null
        # }
        #
        # will become
        #
        # {
        #   "invalidInput"=> {
        #     "id"=>"portal_mf734147",
        #     "context"=>"metadata-field",
        #     "value"=>nil,
        #     "explanation"=>"The metadata value is invalid"
        #   }
        # }
        def error
          _response_parsed = http_client.response_parsed
          if _response_parsed.is_a?(Hash)
            _error = _response_parsed.delete_if { |k,v| v.nil? }
            _error
          else
            _response = http_client.response
            _response.body if _response.respond_to?(:body)
          end
        end

        # ############################################################################################################## #
        # @!group API Endpoints


        def asset_create(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'assets/v1/assets/',
              :http_method => :post,
              :http_success_code => '201',
              :body => args,
              :parameters => [
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def asset_delete(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'assets/v1/assets/#{path_arguments[:asset_id]}/',
              :http_method => :delete,
              :http_success_code => '204',
              :body => args,
              :parameters => [
                { :name => :asset_id, :aliases => [ :id ], :required => true, :send_in => :path },
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end


        def asset_file_create(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'files/v1/assets/#{path_arguments[:asset_id]}/files/',
              :http_method => :post,
              :http_success_code => '201',
              :body => args,
              :parameters => [
                { :name => :asset_id, :required => true, :send_in => :path },

                { :name => :file_set_id, :required => true },
                { :name => :file_date_create, :required => true },
                { :name => :file_date_modified, :required => true },
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def asset_file_update(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'files/v1/assets/#{path_arguments[:asset_id]}/files/#{path_arguments[:file_id]}/',
              :http_method => :patch,
              :http_success_code => '201',
              :body => args,
              :parameters => [
                { :name => :asset_id, :required => true, :send_in => :path },
                { :name => :file_id, :required => true, :send_in => :path },

                { :name => :file_set_id, :required => true },
                { :name => :file_date_create, :required => true },
                { :name => :file_date_modified, :required => true },
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def asset_file_keyframes_create(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'files/v1/assets/#{path_arguments[:asset_id]}/files/#{path_arguments[:file_id]}/keyframes/',
              :http_method => :post,
              :http_success_code => '201',
              :body => args,
              :parameters => [
                { :name => :asset_id, :required => true, :send_in => :path },
                { :name => :file_id, :required => true, :send_in => :path },
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def asset_file_set_create(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'files/v1/assets/#{path_arguments[:asset_id]}/file_sets/',
              :http_method => :post,
              :http_success_code => '201',
              :body => args,
              :parameters => [
                { :name => :asset_id, :required => true, :send_in => :path },
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end
        alias :asset_fileset_create :asset_file_set_create

        def asset_files_get(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'files/v1/assets/#{path_arguments[:asset_id]}/files/',
              :parameters => [
                { :name => :asset_id, :aliases => [ :id ], :required => true, :send_in => :path },
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def asset_format_create(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'files/v1/assets/#{path_arguments[:asset_id]}/formats/',
              :http_method => :post,
              :http_success_code => '201',
              :body => args,
              :parameters => [
                { :name => :asset_id, :required => true, :send_in => :path }
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def asset_format_get_by_name(args = { }, options = { })
          _request = Requests::BaseRequest.new(
              args,
              {
                  :http_path => 'files/v1/assets/#{path_arguments[:asset_id]}/formats/#{path_arguments[:format_name]}/',
                  :http_method => :get,
                  :http_success_code => '201',
                  :body => args,
                  :parameters => [
                      { :name => :asset_id, :required => true, :send_in => :path },
                      { :name => :format_name, :aliases => [ :name ], :send_in => :path }
                  ]
              }.merge(options)
          )
          process_request(_request, options)
        end

        def asset_formats_get(args = { }, options = { })
          _request = Requests::BaseRequest.new(
              args,
              {
                  :http_path => 'files/v1/assets/#{path_arguments[:asset_id]}/formats/',
                  :http_method => :get,
                  :http_success_code => '201',
                  :body => args,
                  :parameters => [
                      { :name => :asset_id, :required => true, :send_in => :path },
                      { :name => :name, :default_value => 'ORIGINAL' },
                      { :name => :metadata }
                  ]
              }.merge(options)
          )
          process_request(_request, options)
        end


        def asset_keyframes_get(args = { }, options = { })

        end

        def asset_metadata_set(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'metadata/v1/assets/#{path_arguments[:asset_id]}/views/#{path_arguments[:view_id]}/',
              :http_method => :put,
              :http_success_code => '201',
              :body => args,
              :parameters => [
                { :name => :asset_id, :required => true, :send_in => :path },
                { :name => :view_id, :required => true, :send_in => :path },
                { :name => :metadata_values }
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def assets_get(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'assets/v1/assets/',
              :default_parameter_send_in_value => :query,
              :parameters => [
                { :name => :per_page },
                { :name => :page },
                { :name => :sort },
                { :name => :filter }
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def assets_reindex(args = { }, options = { })
          http(:post, 'assets/v1/assets/reindex/')
        end

        # def auth_login_ad(args = { }, options = { })
        #
        # end
        #
        # def auth_login_oauth(args = { }, options = { })
        #
        # end

        def auth_login_simple(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'auth/v1/auth/simple/login/',
              :http_method => :post,
              :parameters => [
                { :name => :email, :required => true },
                { :name => :password, :required => true }
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        # @deprecated
        def auth_token_get(args = { }, options = { })
          _token = args[:token] || token
          _token = token.to_s if _token.respond_to?(:to_s)
          http(:get, 'auth/v1/auth/token/', { :headers => { http_client.header_auth_key => _token } })
        end

        # @deprecated
        def auth_token_refresh(args = { }, options = { })
          http(:put, 'auth/v1/auth/token/')
        end

        def collection_create(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'assets/v1/collections/',
              :http_method => :post,
              :http_success_code => '201',
              :body => args,  # Passthrough all arguments passed to the request body
              :parameters => [
                { :name => :title, :aliases => [:collection_title, :collection_name, :name ] },
                { :name => :description },
                { :name => :parent_id },
                { :name => :is_root },
                { :name => :date_created },
                { :name => :description }
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def collection_delete(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'assets/v1/collections/#{path_arguments[:collection_id]}/',
              :http_method => :delete,
              :http_success_code => '201',
              :parameters => [
                { :name => :collection_id, :aliases => [ :id ], :send_in => :path }
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def collection_replace(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'assets/v1/collections/#{path_arguments[:collection_id]}/',
              :http_method => :put,
              :http_success_code => '200',
              :parameters => [
                { :name => :collection_id, :aliases => [ :id ], :send_in => :path },
                { :name => :title, :aliases => [ :collection_title, :collection_name, :name ] },
                { :name => :description },
                { :name => :parent_id },
                { :name => :is_root },
                { :name => :date_created },
                { :name => :description }
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def collection_update(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'assets/v1/collections/#{path_arguments[:collection_id]}/',
              :http_method => :patch,
              :http_success_code => '200',
              :parameters => [
                { :name => :collection_id, :aliases => [ :id ], :send_in => :path },
                { :name => :title, :aliases => [ :collection_title, :collection_name, :name ] },
                { :name => :description },
                { :name => :parent_id },
                { :name => :is_root },
                { :name => :date_created },
                { :name => :description }
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def collection_get(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'assets/v1/collections/#{arguments[:collection_id]}/',
              :body => args,
              :parameters => [
                { :name => :collection_id }
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def collection_content_add(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'assets/v1/collections/#{path_arguments[:collection_id]}/contents/',
              :http_method => :post,
              :http_success_code => '201',
              :body => args,
              :parameters => [
                { :name => :collection_id, :send_in => :path },
                { :name => :object_id },
                { :name => :object_type },
                { :name => :date_created },
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end


        def collection_contents_get(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'assets/v1/collections/#{path_arguments[:collection_id]}/contents/',
              :parameters => [
                { :name => :collection_id, :aliases => [ :id ], :send_in => :path },
                { :name => :content_types }, # Comma separated list of content types. Example - assets,collections
                { :name => :per_page },
                { :name => :page },
                { :name => :sort }, # A comma separated list of fieldnames with order. For example - first_name,asc;last_name,desc
                { :name => :filter }, # A comma separated list of fieldnames with order For example - first_name,eq,Vlad;last_name,eq,Gudkov
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def collections_get(args = { }, options = { })
          http(:get, 'assets/v1/collections/')
        end

        def collections_reindex(args = { }, options = { })
          http(:post, 'assets/collections/reindex/')
        end

        def metadata_field_create(args = { }, options = { })
          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'files/v1/storages/',
              :http_method => :post,
              :http_success_code => '201',
              :body => args,
              :parameters => [
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def storage_create(args = { }, options = { })
          # http(:post, 'files/v1/storages/', args)

          _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'files/v1/storages/',
              :http_method => :post,
              :http_success_code => '201',
              :body => args,
              :parameters => [
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def storage_files_get(args = { }, options = { })
         _request = Requests::BaseRequest.new(
            args,
            {
              :http_path => 'files/v1/storages/#{path_arguments[:storage_id]}/files/',
              :body => args,
              :parameters => [
                { :name => :storage_id, :required => true, :send_in => :path },
                { :name => :path }
              ]
            }.merge(options)
          )
          process_request(_request, options)
        end

        def storages_get(args = { }, options = { })
          http(:get, 'files/v1/storages/')
        end

        def token
          http_client.token
        end

        def token=(token_data)
          http_client.token = token_data
        end

        def transcode(args = { }, options = { })
          _request = Requests::BaseRequest.new(
              args,
              {
                  :http_path => 'transcode/v1/transcode/',
                  :http_method => :post,
                  :http_success_code => '201',
                  :parameters => [
                  ]
              }.merge(options)
          )
          process_request(_request, options)
        end

        # @!endgroup API Endpoints
        # ############################################################################################################## #

        # Client
      end

      # API
    end

    # Iconik
  end

  # Ubiquity
end
