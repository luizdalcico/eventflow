class AllowNullEventDateDate < ActiveRecord::Migration[8.0]
  def change
    change_column_null :event_dates, :date, true
  end
end
