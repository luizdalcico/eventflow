class AddPaidValueAndRelaxProfessionalsOnEventProviders < ActiveRecord::Migration[8.0]
  def up
    add_column :event_providers, :paid_value, :decimal, precision: 12, scale: 2

    # Professionals count is optional now (e.g. a buffet is a whole team, not a headcount).
    change_column_default :event_providers, :professionals_count, from: 1, to: nil
    change_column_null :event_providers, :professionals_count, true
  end

  def down
    change_column_null :event_providers, :professionals_count, false, 1
    change_column_default :event_providers, :professionals_count, from: nil, to: 1
    remove_column :event_providers, :paid_value
  end
end
