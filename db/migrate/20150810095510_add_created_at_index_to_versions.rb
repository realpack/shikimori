class AddCreatedAtIndexToVersions < ActiveRecord::Migration
  def change
    add_index :versions, :created_at
  end
end
