require "test_helper"

class GuestImportTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile

  def setup
    @event = Event.create!(title: "Casamento", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  test "imports the Tipo column into guest_type" do
    result = import("guests_types.csv")

    assert_equal 3, result.imported
    assert_equal "adult", @event.guests.find_by!(name: "Arnóbio").guest_type
    assert_equal "child", @event.guests.find_by!(name: "Sobrinho").guest_type
  end

  test "falls back to the adult default when Tipo is blank or absent" do
    import("guests_types.csv")
    assert_equal "adult", @event.guests.find_by!(name: "Sem Tipo").guest_type

    import("guests.csv")
    assert_equal "adult", @event.guests.find_by!(name: "João Silva").guest_type
  end

  private

  def import(filename)
    file = fixture_file_upload(filename, "text/csv")
    GuestImport.new(@event, file).call
  end
end
