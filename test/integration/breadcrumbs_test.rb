require "test_helper"

# Every navigable flow renders the shared breadcrumb trail. We assert one
# representative page per flow plus the trail's structure on a deep page.
class BreadcrumbsTest < ActionDispatch::IntegrationTest
  setup do
    @event = Event.create!(title: "Casamento Teste", event_type: "wedding",
                           main_date: 1.month.from_now.to_date, estimated_guests: 100)
    @provider = Provider.create!(provider_type: "photographer", name: "Foto & Arte",
                                 contact_name: "Paulo", phone_number: "85999990000", document: "")
  end

  test "events index (home) does not render a breadcrumb trail" do
    get events_url
    assert_response :success
    assert_select "nav[aria-label=?]", "Breadcrumb", count: 0
  end

  test "event show breadcrumb links back to the events list" do
    get event_url(@event)
    assert_response :success
    assert_select "nav[aria-label=?]", "Breadcrumb" do
      assert_select "a[href=?]", events_path, text: "Eventos"
      # Current page is the event itself, rendered as plain text.
      assert_select "span[aria-current=?]", "page", text: @event.title
    end
  end

  test "event owners index breadcrumb chains events to the event to responsaveis" do
    get event_event_owners_url(@event)
    assert_response :success
    assert_select "nav[aria-label=?]", "Breadcrumb" do
      assert_select "a[href=?]", events_path, text: "Eventos"
      assert_select "a[href=?]", event_path(@event), text: @event.title
      assert_select "span[aria-current=?]", "page", text: "Responsáveis"
    end
  end

  test "guests index renders a breadcrumb trail" do
    get event_guests_url(@event)
    assert_response :success
    assert_select "nav[aria-label=?]", "Breadcrumb" do
      assert_select "a[href=?]", event_path(@event), text: @event.title
      assert_select "span[aria-current=?]", "page", text: "Convidados"
    end
  end

  test "event providers index renders a breadcrumb trail" do
    get event_event_providers_url(@event)
    assert_response :success
    assert_select "nav[aria-label=?]", "Breadcrumb" do
      assert_select "span[aria-current=?]", "page", text: "Fornecedores"
    end
  end

  test "event dates index renders a breadcrumb trail" do
    get event_event_dates_url(@event)
    assert_response :success
    assert_select "nav[aria-label=?]", "Breadcrumb" do
      assert_select "span[aria-current=?]", "page", text: "Outras datas"
    end
  end

  test "cortejo renders a breadcrumb trail" do
    get event_cortejo_url(@event)
    assert_response :success
    assert_select "nav[aria-label=?]", "Breadcrumb" do
      assert_select "span[aria-current=?]", "page", text: "Cortejo"
    end
  end

  test "manager checklist index renders a breadcrumb trail" do
    get event_manager_checklists_url(@event)
    assert_response :success
    assert_select "nav[aria-label=?]", "Breadcrumb" do
      assert_select "a[href=?]", event_path(@event), text: @event.title
    end
  end

  test "owner checklist index renders a breadcrumb trail" do
    get event_owner_checklists_url(@event)
    assert_response :success
    assert_select "nav[aria-label=?]", "Breadcrumb" do
      assert_select "a[href=?]", event_path(@event), text: @event.title
    end
  end

  test "providers index (section root) does not render a breadcrumb trail" do
    get providers_url
    assert_response :success
    assert_select "nav[aria-label=?]", "Breadcrumb", count: 0
  end

  test "provider show breadcrumb links back to the providers list" do
    get provider_url(@provider)
    assert_response :success
    assert_select "nav[aria-label=?]", "Breadcrumb" do
      assert_select "a[href=?]", providers_path, text: "Fornecedores"
      assert_select "span[aria-current=?]", "page", text: @provider.name
    end
  end
end
