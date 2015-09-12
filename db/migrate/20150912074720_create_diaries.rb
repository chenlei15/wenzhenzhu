class CreateDiaries < ActiveRecord::Migration
  def change
    create_table :diaries do |t|
      t.string :title
      t.text :body
      t.date :date
      t.integer :user_id

      t.timestamps
    end
  end
end
