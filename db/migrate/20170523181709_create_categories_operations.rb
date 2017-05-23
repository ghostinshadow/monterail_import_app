class CreateCategoriesOperations < ActiveRecord::Migration
  def change
    create_table :categories_operations do |t|
      t.integer :category_id
      t.integer :operation_id
    end
  end
end
