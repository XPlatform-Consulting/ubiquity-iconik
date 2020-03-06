source_app_id = ''
source_app_token = ''
source_client_args = { :application_id => source_app_id, :token => source_app_token }

target_app_id = ''
target_app_token = ''
target_client_args = { :application_id => target_app_id, :token => target_app_token }

require 'pp'
require 'ubiquity/iconik/api/utilities'

@source_api = Ubiquity::Iconik::API::Utilities.new(source_client_args)
def source_api; @source_api end

@target_api = Ubiquity::Iconik::API::Utilities.new(target_client_args)
def target_api; @target_api end


class MetadataSchemaImporter

  attr_reader :api, :schema, :view_map

  def initialize(args = {}, options = {})
    @api = args[:api]
    @schema = args[:schema]
    @view_map = {}
  end

  def import_categories
    categories = schema[:categories]
    categories.each do |k, objects|
      next unless objects
      objects = [ objects ] unless objects.is_a?(Array)
      objects.each do |category|
        category_out = category.dup
        view_ids = category_out['view_ids']
        view_ids.map! { |vid| view_map[vid] }
        view_ids.compact!
        next if view_ids.empty?
        category_out['view_ids'] = view_ids
        api.metadata_object_type_categories_set(category_out)
      end
    end
  end

  def import_fields
    fields = schema[:fields]
    fields.each do |field|
      next if field['name'].start_with?('_')
      field_out = field.dup
      field.each { |k,v| field_out.delete(k) if v.nil? }
      api.metadata_field_create(field_out)
    end
  end

  def import_views
    views = schema[:views]
    views.each do |view|
      resp = api.metadata_view_create(view)
      view_id_previous = view['id']
      view_id_new = resp['id']
      @view_map[view_id_previous] = view_id_new
    end
  end

  def run
    import_fields
    import_views
    import_categories
  end

end

schema = source_api.metadata_schema_get
importer = MetadataSchemaImporter.new(api: target_api, schema: schema)
importer.run
