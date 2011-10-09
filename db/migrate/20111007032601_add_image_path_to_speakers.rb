class AddImagePathToSpeakers < ActiveRecord::Migration
  def self.up
    add_column :speakers, :image_path, :text
  end

  def self.down
    remove_column :speakers, :image_path
  end
end
