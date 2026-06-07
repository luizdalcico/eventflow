require "test_helper"

class CortejoControllerTest < ActionDispatch::IntegrationTest
  def setup
    @event = Event.create!(title: "Casamento", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  test "show renders the procession section" do
    get event_cortejo_path(@event)
    assert_response :success
    assert_select "h2", text: /Cortejo/
  end

  test "show no longer renders the familiares section" do
    @event.family_members.create!(name: "Maria", role: "mae_noiva", position: 1)

    get event_cortejo_path(@event)
    assert_response :success
    assert_select "h2", text: "Familiares", count: 0
  end

  test "show no longer renders the padrinhos section" do
    get event_cortejo_path(@event)
    assert_response :success
    assert_select "h2", text: "Padrinhos", count: 0
  end
end
