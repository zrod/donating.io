class RenameReponseToParsedResponseInGeoTerms < ActiveRecord::Migration[8.1]
  def change
    rename_column :geo_terms, :response, :parsed_response
  end
end
