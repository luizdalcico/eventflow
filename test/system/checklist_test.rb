require "application_system_test_case"

class ChecklistTest < ApplicationSystemTestCase
  def setup
    @event = Event.create!(title: "Casamento X", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  test "checklist: add a task, mark done, responsive" do
    page.driver.browser.manage.window.resize_to(1200, 900)
    visit event_manager_checklists_path(@event)

    assert_selector "h1", text: "Checklist"
    assert_text "Nenhuma tarefa ainda"

    fill_in "Nova tarefa…", with: "Contratar buffet"
    click_button "Adicionar"

    assert_field "manager_checklist[task]", with: "Contratar buffet"
    assert_equal 1, @event.manager_checklists.count

    # Marcar como concluída aplica o risco e persiste.
    find("input[type=checkbox]").check
    assert_selector "input.line-through", wait: 3
    page.save_screenshot(Rails.root.join("tmp/checklist_desktop.png").to_s)

    page.driver.browser.manage.window.resize_to(390, 850)
    page.save_screenshot(Rails.root.join("tmp/checklist_mobile.png").to_s)
  end
end
