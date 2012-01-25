class CreateConversions < ActiveRecord::Migration
  def change
    create_table :conversions do |t|
      t.string :document_name, :limit => 500
      t.string :document_path, :limit => 1000
      t.integer :num_of_pages
      t.string :location, :limit => 500
      t.boolean :converted
      t.timestamp :uploaded_at
      t.timestamps
    end
  end
end
