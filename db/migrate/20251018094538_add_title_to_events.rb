class AddTitleToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :title, :string
  end
end
