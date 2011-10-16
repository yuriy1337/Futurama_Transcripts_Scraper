class CreateExchanges < ActiveRecord::Migration
  def self.up
    create_table :exchanges do |t|
      t.integer :id1
      t.integer :id2
      t.integer :count

      t.timestamps
    end
  end

  def self.down
    drop_table :exchanges
  end
end
