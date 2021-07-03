class Addlikestodog < ActiveRecord::Migration[5.2]
  def change
    change_table :dogs do |t|
      t.integer :likes
    end
  end
end
