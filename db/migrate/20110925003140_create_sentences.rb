class CreateSentences < ActiveRecord::Migration
  def self.up
    create_table :sentences do |t|
      t.integer :speaker_id
      t.integer :episode_id
      t.text :sentence
      t.integer :num_of_words
      t.integer :num_of_chars

      t.timestamps
    end
  end

  def self.down
    drop_table :sentences
  end
end
