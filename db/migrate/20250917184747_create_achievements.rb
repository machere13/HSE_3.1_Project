class CreateAchievements < ActiveRecord::Migration[8.0]
  def change
    create_table :achievements do |t|
      t.string :name
      t.text :description
      t.string :category
      t.string :progress_type
      t.integer :progress_target

      t.timestamps
    end
  end
end
