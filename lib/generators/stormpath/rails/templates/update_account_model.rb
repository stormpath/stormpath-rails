class AddStormpathUrlTo<%= model_name.pluralize.camelize %> < ActiveRecord::Migration
  def up
    add_column :<%= model_name.pluralize %>, :stormpath_url, :string
    add_index :<%= model_name.pluralize %>, :stormpath_url
  end

  def down
    remove_column :<%= model_name.pluralize %>, :stormpath_url
  end
end