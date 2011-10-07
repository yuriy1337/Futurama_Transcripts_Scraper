class CreateCounts < ActiveRecord::Migration
  def self.up
    create_table :counts do |t|
      t.integer :episode_id
      t.integer :speaker_id
      t.integer :word_id
      t.integer :count

      t.timestamps
    end
  end

  def self.down
    drop_table :counts
  end
end
