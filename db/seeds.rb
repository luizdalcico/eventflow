# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Criando dados de exemplo..."

# Clean existing data (only in development)
if Rails.env.development?
  puts "Limpando dados existentes..."
  Event.destroy_all
  Provider.destroy_all
end

# Create Providers
puts "Criando fornecedores..."

photographers = [
  { name: "Estúdio Visual", contact_name: "Carlos Silva", phone_number: "(11) 98765-4321", document: "12.345.678/0001-90" },
  { name: "Momentos Fotografia", contact_name: "Ana Santos", phone_number: "(11) 99876-5432", document: "23.456.789/0001-01" }
]

buffets = [
  { name: "Buffet Delícias", contact_name: "João Oliveira", phone_number: "(11) 97654-3210", document: "34.567.890/0001-12" },
  { name: "Sabor & Arte", contact_name: "Maria Costa", phone_number: "(11) 96543-2109", document: "45.678.901/0001-23" }
]

decorations = [
  { name: "Flores & Sonhos", contact_name: "Paula Rodrigues", phone_number: "(11) 95432-1098", document: "56.789.012/0001-34" },
  { name: "Decorart", contact_name: "Roberto Lima", phone_number: "(11) 94321-0987", document: "67.890.123/0001-45" }
]

musics = [
  { name: "Banda Harmonia", contact_name: "Pedro Alves", phone_number: "(11) 93210-9876", document: "78.901.234/0001-56" },
  { name: "DJ Sound Mix", contact_name: "Lucas Martins", phone_number: "(11) 92109-8765", document: "89.012.345/0001-67" }
]

photographers.each do |attrs|
  Provider.find_or_create_by!(name: attrs[:name]) do |provider|
    provider.provider_type = "photographer"
    provider.contact_name = attrs[:contact_name]
    provider.phone_number = attrs[:phone_number]
    provider.document = attrs[:document]
  end
end

buffets.each do |attrs|
  Provider.find_or_create_by!(name: attrs[:name]) do |provider|
    provider.provider_type = "buffet"
    provider.contact_name = attrs[:contact_name]
    provider.phone_number = attrs[:phone_number]
    provider.document = attrs[:document]
  end
end

decorations.each do |attrs|
  Provider.find_or_create_by!(name: attrs[:name]) do |provider|
    provider.provider_type = "decoration"
    provider.contact_name = attrs[:contact_name]
    provider.phone_number = attrs[:phone_number]
    provider.document = attrs[:document]
  end
end

musics.each do |attrs|
  Provider.find_or_create_by!(name: attrs[:name]) do |provider|
    provider.provider_type = "music_band"
    provider.contact_name = attrs[:contact_name]
    provider.phone_number = attrs[:phone_number]
    provider.document = attrs[:document]
  end
end

puts "#{Provider.count} fornecedores criados."

# Create Events
puts "Criando eventos..."

# Wedding Event
wedding = Event.find_or_create_by!(
  event_type: "wedding",
  main_date: 3.months.from_now.to_date
) do |event|
  event.title = "Casamento Marina & Rafael"
  event.start_time = "18:00"
  event.end_time = "23:00"
  event.place = "Igreja São Paulo e Salão de Festas Jardim"
  event.address = "Rua das Flores, 123 - Jardim Paulista, São Paulo - SP"
  event.estimated_guests = 150
  event.extra_hours = 2.0
end

# Create Event Owners for Wedding
wedding.event_owners.find_or_create_by!(name: "Marina Fernandes") do |owner|
  owner.cpf = "123.456.789-01"
  owner.email = "marina.fernandes@example.com"
  owner.phone_number = "(11) 98888-1111"
  owner.role = "Noiva"
end

wedding.event_owners.find_or_create_by!(name: "Rafael Costa") do |owner|
  owner.cpf = "987.654.321-09"
  owner.email = "rafael.costa@example.com"
  owner.phone_number = "(11) 97777-2222"
  owner.role = "Noivo"
end

# Birthday Event
birthday = Event.find_or_create_by!(
  event_type: "adult_birthday",
  main_date: 1.month.from_now.to_date
) do |event|
  event.title = "Aniversário de 30 anos da Carla"
  event.start_time = "20:00"
  event.end_time = "23:59"
  event.place = "Salão de Festas Villa Real"
  event.address = "Av. Paulista, 456 - Bela Vista, São Paulo - SP"
  event.estimated_guests = 80
  event.extra_hours = 1.0
end

birthday.event_owners.find_or_create_by!(name: "Carla Mendes") do |owner|
  owner.cpf = "456.789.123-45"
  owner.email = "carla.mendes@example.com"
  owner.phone_number = "(11) 96666-3333"
  owner.role = "Aniversariante"
end

# Corporate Event
corporate = Event.find_or_create_by!(
  event_type: "corporate_event",
  main_date: 2.weeks.from_now.to_date
) do |event|
  event.title = "Convenção Anual Corporativa"
  event.start_time = "08:00"
  event.end_time = "18:00"
  event.place = "Centro de Convenções SP"
  event.address = "Rua do Evento, 789 - Centro, São Paulo - SP"
  event.estimated_guests = 300
  event.extra_hours = 0
end

corporate.event_owners.find_or_create_by!(name: "José Pereira") do |owner|
  owner.cpf = "789.123.456-78"
  owner.email = "jose.pereira@example.com"
  owner.phone_number = "(11) 95555-4444"
  owner.role = "Organizador"
end

puts "#{Event.count} eventos criados."

# Add Event Dates
puts "Adicionando datas extras aos eventos..."

wedding.event_dates.find_or_create_by!(description: "Casamento Civil") do |date|
  date.date = wedding.main_date - 1.week
end

wedding.event_dates.find_or_create_by!(description: "Ensaio de Fotos") do |date|
  date.date = wedding.main_date - 2.weeks
end

birthday.event_dates.find_or_create_by!(description: "Decoração do Local") do |date|
  date.date = birthday.main_date - 1.day
end

# Add some guests
puts "Adicionando convidados..."

# Wedding guests with godparents
godfather = wedding.guests.find_or_create_by!(name: "Pedro Silva") do |guest|
  guest.cpf = "111.222.333-44"
  guest.phone_number = "(11) 94444-5555"
  guest.is_godparent = true
end

godmother = wedding.guests.find_or_create_by!(name: "Ana Silva") do |guest|
  guest.cpf = "222.333.444-55"
  guest.phone_number = "(11) 93333-6666"
  guest.is_godparent = true
  guest.godparent_pair = godfather
end

# Update godfather to pair with godmother
godfather.update!(godparent_pair: godmother)

# Regular guests
[ "Marcos Santos", "Julia Lima", "Fernando Rodrigues", "Camila Alves" ].each do |name|
  wedding.guests.find_or_create_by!(name: name) do |guest|
    guest.phone_number = "(11) 9#{rand(1000..9999)}-#{rand(1000..9999)}"
  end
end

# Birthday guests
[ "Ricardo Ferreira", "Beatriz Costa", "Daniel Oliveira" ].each do |name|
  birthday.guests.find_or_create_by!(name: name) do |guest|
    guest.phone_number = "(11) 9#{rand(1000..9999)}-#{rand(1000..9999)}"
  end
end

puts "#{Guest.count} convidados criados."

# Add providers to events
puts "Associando fornecedores aos eventos..."

# Wedding providers
photographer = Provider.find_by(provider_type: "photographer", name: "Estúdio Visual")
buffet = Provider.find_by(provider_type: "buffet", name: "Buffet Delícias")
decoration = Provider.find_by(provider_type: "decoration", name: "Flores & Sonhos")
music = Provider.find_by(provider_type: "music_band", name: "Banda Harmonia")

if photographer
  wedding.event_providers.find_or_create_by!(provider: photographer) do |ep|
    ep.custom_details = {
      "horas_contratadas" => "8",
      "tipo_album" => "Premium",
      "numero_fotos" => "500+"
    }
  end
end

if buffet
  wedding.event_providers.find_or_create_by!(provider: buffet) do |ep|
    ep.custom_details = {
      "tipo_cardapio" => "Jantar completo",
      "numero_convidados" => "150",
      "inclui_bebidas" => "Sim"
    }
  end
end

if decoration
  wedding.event_providers.find_or_create_by!(provider: decoration) do |ep|
    ep.custom_details = {
      "tema" => "Romântico clássico",
      "cores" => "Branco e rosa",
      "inclui_flores" => "Bouquet e arranjos"
    }
  end
end

# Birthday providers
photographer2 = Provider.find_by(provider_type: "photographer", name: "Momentos Fotografia")
dj = Provider.find_by(provider_type: "music_band", name: "DJ Sound Mix")

if photographer2
  birthday.event_providers.find_or_create_by!(provider: photographer2) do |ep|
    ep.custom_details = {
      "horas_contratadas" => "6",
      "tipo_cobertura" => "Festa completa"
    }
  end
end

if dj
  birthday.event_providers.find_or_create_by!(provider: dj) do |ep|
    ep.custom_details = {
      "equipamento" => "Som completo + iluminação",
      "repertorio" => "Anos 80, 90 e atuais"
    }
  end
end

puts "Fornecedores associados aos eventos."

# Add checklist tasks
puts "Criando Checklist..."

wedding.manager_checklists.find_or_create_by!(task: "Confirmar cardápio com buffet") do |task|
  task.due_date = wedding.main_date - 2.weeks
  task.reminder_date = wedding.main_date - 3.weeks
  task.completed = false
end

wedding.manager_checklists.find_or_create_by!(task: "Verificar decoração do local") do |task|
  task.due_date = wedding.main_date - 1.week
  task.reminder_date = wedding.main_date - 10.days
  task.completed = false
end

wedding.manager_checklists.find_or_create_by!(task: "Coordenar ensaio fotográfico") do |task|
  task.due_date = wedding.main_date - 2.weeks
  task.reminder_date = wedding.main_date - 3.weeks
  task.completed = true
end

wedding.manager_checklists.find_or_create_by!(task: "Enviar lista final de convidados") do |task|
  task.due_date = wedding.main_date - 1.month
  task.reminder_date = wedding.main_date - 6.weeks
  task.completed = true
end

wedding.manager_checklists.find_or_create_by!(task: "Buscar alianças") do |task|
  task.due_date = wedding.main_date - 3.days
  task.reminder_date = wedding.main_date - 1.week
  task.completed = false
end

birthday.manager_checklists.find_or_create_by!(task: "Confirmar equipamento de som") do |task|
  task.due_date = birthday.main_date - 3.days
  task.reminder_date = birthday.main_date - 1.week
  task.completed = false
end

birthday.manager_checklists.find_or_create_by!(task: "Definir lista de músicas") do |task|
  task.due_date = birthday.main_date - 1.week
  task.reminder_date = birthday.main_date - 2.weeks
  task.completed = false
end

puts "#{ManagerChecklist.count} tarefas de Checklist criadas."

puts "\n✅ Dados de exemplo criados com sucesso!"
puts "\nResumo:"
puts "- #{Event.count} eventos"
puts "- #{Provider.count} fornecedores"
puts "- #{Guest.count} convidados"
puts "- #{EventProvider.count} associações evento-fornecedor"
puts "- #{ManagerChecklist.count} tarefas de Checklist"
puts "\nAcesse http://localhost:3000 para ver a aplicação!"
