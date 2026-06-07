class AddCostFieldsToEventProviders < ActiveRecord::Migration[8.0]
  def up
    add_column :event_providers, :value, :decimal, precision: 12, scale: 2
    add_column :event_providers, :status, :string, null: false, default: "pendente"
    add_column :event_providers, :professionals_count, :integer, null: false, default: 1

    # Backfill the new value column from the legacy custom_details["value"] (BRL string),
    # in the same migration so existing rows are not left behind.
    EventProvider.reset_column_information
    EventProvider.find_each do |ep|
      raw = ep.custom_details.is_a?(Hash) ? ep.custom_details["value"] : nil
      parsed = parse_brl(raw)
      ep.update_columns(value: parsed) unless parsed.nil?
    end
  end

  def down
    remove_column :event_providers, :professionals_count
    remove_column :event_providers, :status
    remove_column :event_providers, :value
  end

  private

  # Parse a Brazilian-formatted money string ("R$ 1.234,56") into a BigDecimal.
  # Returns nil when blank or unparseable.
  def parse_brl(raw)
    return nil if raw.nil?
    return raw if raw.is_a?(Numeric)

    digits = raw.to_s.gsub(/[^\d,.-]/, "").tr(".", "").tr(",", ".")
    return nil if digits.blank?

    BigDecimal(digits)
  rescue ArgumentError
    nil
  end
end
