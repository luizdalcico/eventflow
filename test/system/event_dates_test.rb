require "application_system_test_case"

class EventDatesTest < ApplicationSystemTestCase
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.current + 2.months, estimated_guests: 100)
    @event.event_owners.create!(name: "Marina", phone_number: "85999990000", email: "m@x.com")
  end

  test "add an event date" do
    page.driver.browser.manage.window.resize_to(1200, 900)
    visit event_event_dates_path(@event)

    assert_selector "h1", text: "Outras datas"
    assert_text "Nenhuma data adicional"

    fill_in "Descrição (ex: Ensaio fotográfico)", with: "Ensaio"
    fill_in "event_date[date]", with: (Date.current + 1.month).strftime("%Y-%m-%d")
    click_button "Adicionar"

    assert_field "event_date[description]", with: "Ensaio"
    assert_equal 1, @event.event_dates.count
    page.save_screenshot(Rails.root.join("tmp/event_dates.png").to_s)
  end

  test "event owners management page renders" do
    visit event_event_owners_path(@event)
    assert_text "Marina"
  end
end
