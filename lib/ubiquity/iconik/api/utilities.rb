require 'ubiquity/iconik/api/client'

module Ubiquity
  module Iconik
    module API
      class Utilities < Client

        # Converts hash keys to symbols
        #
        # @param [Hash] value hash
        # @param [Boolean] recursive Will recurse into any values that are hashes or arrays
        def symbolize_keys (value, recursive = true)
          case value
          when Hash
            new_val = {}
            value.each { |k, v|
              k          = (k.to_sym rescue k)
              v          = symbolize_keys(v, true) if recursive and (v.is_a? Hash or v.is_a? Array)
              new_val[k] = v
            }
            return new_val
          when Array
            return value.map { |v| symbolize_keys(v, true) }
          else
            return value
          end
        end


        # @param [Object]  args
        # @param [Object]  options
        # @return [Hash]
        def asset_metadata_set_extended(args = {}, options = {})
          _args           = symbolize_keys(args, false)
          asset_id        = _args[:asset_id]
          default_view_id = _args[:view_id]
          metadata        = _args[:metadata]

          responses = {}
          metadata.each do |view|
            values_out = {}
            view_id    = view['id'] || view[:id] || default_view_id
            values     = view['metadata_values'] || view[:metadata_values]
            values.echo do |k, v|
              values_out[k] = { :field_values => [v] }
            end
            args_out           = {
                :asset_id        => asset_id,
                :view_id         => view_id,
                :metadata_values => values_out
            }
            r                  = asset_metadata_set(args_out, options)
            responses[view_id] = r
          end

          { :responses => responses }
        end

        # @param [Object]  args
        # @param [Object]  options
        # @return [Hash]
        def asset_add_using_file_path(args = {}, options = {})
          _args     = symbolize_keys(args, false)
          file_path = _args[:file_path]
          raise ArgumentError, ':file_path is a required argument.' unless file_path
          file_dir  = File.dirname(file_path)
          file_dir  = '' if file_dir == '.'
          file_name = File.basename(file_path)

          file_size = _args[:file_size] || 1024
          file_type = 'FILE'
          metadata  = _args[:metadata]

          # Determine Storage
          storage_id = _args[:storage_id]
          raise ArgumentError, ':storage_id is a required argument.' unless storage_id

          # Create Asset
          asset_create_args = {
              :title => file_name
          }
          asset             = asset_create(asset_create_args)
          asset_id          = asset['id']
          raise 'Error Creating Asset.' unless asset_id

          # Create Asset Format
          asset_format_create_args = {
              :asset_id => asset_id
          }
          format                   = asset_format_create(asset_format_create_args)
          format_id                = format['id']
          raise 'Error Creating Format.' unless format_id

          # Create Asset File Set
          asset_file_set_create_args = {
              :asset_id      => asset_id,
              :storage_id    => storage_id,
              :format_id     => format_id,

              :name          => file_name,
              :base_dir      => file_dir,
              :component_ids => [],
          }
          file_set                   = asset_file_set_create(asset_file_set_create_args)
          file_set_id                = file_set['id']
          raise 'Error Creating File Set.' unless file_set_id

          # Create Asset File
          file_status                 = args[:file_status] || 'CLOSED'
          file_create_and_modify_time = Time.now.to_s
          asset_file_create_args      = {
              :asset_id           => asset_id,
              :storage_id         => storage_id,
              :format_id          => format_id,
              :file_set_id        => file_set_id,

              :name               => file_name,
              :original_name      => file_name,
              :directory_path     => file_dir,
              :size               => file_size,
              :type               => file_type,
              :status             => file_status,

              :file_date_created  => file_create_and_modify_time,
              :file_date_modified => file_create_and_modify_time,

              :metadata           => {},
          }
          file                        = asset_file_create(asset_file_create_args)
          file_id                     = file['id'] if file.is_a?(Hash)
          raise "Error Creating File. #{file}" unless file && file_id

          asset_file_keyframes_create(:asset_id => asset_id, :file_id => file_id)

          if metadata
            unless metadata.empty?
              metadata[:asset_id] = asset_id
              metadata_set        = asset_metadata_set(metadata)
            end
          end

          { :asset => asset, :format => format, :file_set => file_set, :file => file, :metadata_set => metadata_set }
        end

      end
    end
  end
end
