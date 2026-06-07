class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Parse a Brazilian-formatted money string ("R$ 1.234,56") into a BigDecimal.
  # Returns nil when blank or unparseable, and passes numerics straight through.
  def self.parse_brl(raw)
    return nil if raw.nil?
    return raw if raw.is_a?(Numeric)

    digits = raw.to_s.gsub(/[^\d,.-]/, "").tr(".", "").tr(",", ".")
    return nil if digits.blank?

    BigDecimal(digits)
  rescue ArgumentError
    nil
  end
end
