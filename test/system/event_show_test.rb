require "application_system_test_case"

class EventShowTest < ApplicationSystemTestCase
  def setup
    @event = Event.create!(title: "Casamento Marina & Rafael", event_type: "wedding",
                           main_date: Date.current + 2.months, start_time: "18:00", end_time: "23:00",
                           place: "Salão Jardim", address: "Rua das Flores, 123",
                           estimated_guests: 150, extra_hours: 2)
    @event.event_owners.create!(name: "Marina Fernandes", phone_number: "85999990000", email: "m@x.com", role: "Noiva")
    @event.guests.create!(name: "João Silva", phone_number: "85988887777", rsvp_status: "confirmed")
    @event.guests.create!(name: "Maria Souza", phone_number: "85977776666")
    @event.godparents.create!(role: "madrinha", name: "Ana", position: 1)
  end

  test "event show page renders with header, stats and sections" do
    page.driver.browser.manage.window.resize_to(1400, 1000)
    visit event_path(@event)

    assert_selector "h1", text: "Casamento Marina & Rafael"
    assert_text "Convidados"
    assert_text "Responsáveis"
    assert_link "Editar"
    page.save_screenshot(Rails.root.join("tmp/event_show_desktop.png").to_s)

    page.driver.browser.manage.window.resize_to(390, 900)
    page.save_screenshot(Rails.root.join("tmp/event_show_mobile.png").to_s)
  end
end
