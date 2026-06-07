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

  # The downloaded .xlsx template must round-trip: its Tipo column is read back
  # into guest_type when the filled-in model is re-imported.
  test "reads the Tipo column from an xlsx that mirrors the model template" do
    file = xlsx_upload([
      [ "Nome", "Quantidade de convidados", "Tipo", "Telefone", "Observações" ],
      [ "Maria", 1, "Adulto", "(85) 99999-0000", "" ],
      [ "Lucas", 1, "Criança", "", "" ]
    ])

    result = GuestImport.new(@event, file).call

    assert_equal 2, result.imported
    assert_equal "adult", @event.guests.find_by!(name: "Maria").guest_type
    assert_equal "child", @event.guests.find_by!(name: "Lucas").guest_type
  end

  private

  def import(filename)
    file = fixture_file_upload(filename, "text/csv")
    GuestImport.new(@event, file).call
  end

  # Builds an in-memory .xlsx from rows and wraps it as an uploaded file.
  def xlsx_upload(rows)
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "Convidados") do |sheet|
      rows.each { |row| sheet.add_row row }
    end

    path = File.join(Dir.tmpdir, "guests_model_test.xlsx")
    package.serialize(path)
    Rack::Test::UploadedFile.new(path, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  end
end
