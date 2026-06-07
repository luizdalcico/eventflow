require "test_helper"

class RsvpFlowTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def setup
    @event = Event.create!(title: "Casamento", event_type: "wedding",
                           main_date: Date.current + 1.month, estimated_guests: 100)
  end

  test "index renders the editable guest table" do
    @event.guests.create!(name: "João", phone_number: "85999990000")
    get event_guests_path(@event)
    assert_response :success
    assert_select "h1", text: "Convidados"
    assert_select "input[name='guest[name]'][value=?]", "João"
    assert_select "a", text: /Baixar modelo/
  end

  test "template downloads an xlsx file" do
    get template_event_guests_path(@event)
    assert_response :success
    assert_equal "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", response.media_type
    assert_match(/modelo_convidados\.xlsx/, response.headers["Content-Disposition"])
  end

  test "import creates guests from a CSV, skipping blank-name rows" do
    # 3 nomes válidos (João, Maria, Pedro); a linha sem nome é ignorada.
    assert_difference -> { @event.guests.count }, 3 do
      post import_event_guests_path(@event),
           params: { file: fixture_file_upload("guests.csv", "text/csv") }
    end
    assert_redirected_to event_guests_path(@event)
    joao = @event.guests.find_by(name: "João Silva")
    assert_equal "85999990001", joao.phone_number          # telefone limpo (só dígitos)
    pedro = @event.guests.find_by(name: "Pedro Costa")
    assert_nil pedro.phone_number                          # importado mesmo sem telefone
    assert_not pedro.rsvp_invitable?
  end

  test "import maps quantidade, presença (SIM/NÃO) and observações" do
    post import_event_guests_path(@event),
         params: { file: fixture_file_upload("guests_full.csv", "text/csv") }

    arnobio = @event.guests.find_by(name: "Arnóbio e Tânia")
    assert_equal 2, arnobio.party_size
    assert_equal "confirmed", arnobio.rsvp_status
    assert_equal "Mesa 1", arnobio.notes

    assert_equal "declined", @event.guests.find_by(name: "Carlos Recusado").rsvp_status

    sem = @event.guests.find_by(name: "Sem Resposta")
    assert_equal 3, sem.party_size
    assert_equal "pending", sem.rsvp_status
  end

  test "create adds a blank guest row (inline registration)" do
    assert_difference -> { @event.guests.count }, 1 do
      post event_guests_path(@event), as: :turbo_stream
    end
    assert_equal 1, @event.guests.last.party_size
  end

  test "update saves inline-edited fields" do
    guest = @event.guests.create!
    patch event_guest_path(@event, guest), params: {
      guest: { name: "Ana", phone_number: "(85) 99999-0000", party_size: "2", notes: "Mesa 5" }
    }
    guest.reload
    assert_equal "Ana", guest.name
    assert_equal "85999990000", guest.phone_number
    assert_equal 2, guest.party_size
    assert_equal "Mesa 5", guest.notes
  end

  test "update marks RSVP manually and stamps the response time" do
    guest = @event.guests.create!(name: "Ana", phone_number: "85999990000")
    patch event_guest_path(@event, guest), params: { guest: { rsvp_status: "confirmed" } }
    guest.reload
    assert_equal "confirmed", guest.rsvp_status
    assert guest.rsvp_responded_at.present?
  end

  test "destroy removes a guest" do
    guest = @event.guests.create!(name: "Temp")
    assert_difference -> { @event.guests.count }, -1 do
      delete event_guest_path(@event, guest), as: :turbo_stream
    end
  end

  test "send_rsvp to a single guest enqueues one job" do
    guest = @event.guests.create!(name: "João", phone_number: "85999990000")
    assert_enqueued_jobs 1, only: SendRsvpJob do
      post send_rsvp_event_guests_path(@event), params: { guest_ids: [guest.id] }
    end
    assert_redirected_to event_guests_path(@event)
  end

  test "send_rsvp all enqueues a job for every guest with phone" do
    @event.guests.create!(name: "A", phone_number: "85999990001")
    @event.guests.create!(name: "B", phone_number: "85999990002")
    @event.guests.create!(name: "Sem fone")
    assert_enqueued_jobs 2, only: SendRsvpJob do
      post send_rsvp_event_guests_path(@event), params: { all: "1" }
    end
  end

  test "send_rsvp skips guests already sent or responded" do
    @event.guests.create!(name: "Pendente", phone_number: "85999990001")
    @event.guests.create!(name: "Já enviado", phone_number: "85999990002", rsvp_status: "sent")
    @event.guests.create!(name: "Confirmado", phone_number: "85999990003", rsvp_status: "confirmed")

    # Só o pendente é enviado, mesmo pedindo "todos".
    assert_enqueued_jobs 1, only: SendRsvpJob do
      post send_rsvp_event_guests_path(@event), params: { all: "1" }
    end
  end

  test "send_rsvp enqueues a job per selected invitable guest" do
    g1 = @event.guests.create!(name: "João", phone_number: "85999990000")
    g2 = @event.guests.create!(name: "Sem fone") # not invitable

    assert_enqueued_jobs 1, only: SendRsvpJob do
      post send_rsvp_event_guests_path(@event), params: { guest_ids: [g1.id, g2.id] }
    end
    assert_redirected_to event_guests_path(@event)
  end

  test "webhook confirms RSVP from a quick-reply button payload" do
    guest = @event.guests.create!(name: "João", phone_number: "85999990000")
    guest.mark_rsvp_sent!("SM123")

    post webhooks_twilio_whatsapp_path, params: {
      From: "whatsapp:+5585999990000", ButtonPayload: "rsvp_yes", Body: "Confirmo"
    }
    assert_response :success
    assert_equal "confirmed", guest.reload.rsvp_status
  end

  test "webhook declines RSVP from a quick-reply button payload" do
    guest = @event.guests.create!(name: "João", phone_number: "85999990000")
    guest.mark_rsvp_sent!("SM124")

    post webhooks_twilio_whatsapp_path, params: {
      From: "whatsapp:+5585999990000", ButtonPayload: "rsvp_no", Body: "Não poderei"
    }
    assert_response :success
    assert_equal "declined", guest.reload.rsvp_status
  end
end
