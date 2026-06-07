# Idempotent production seed for real suppliers (Providers).
#
# Data was extracted from the event managers' working files (the per-event
# "PROFISSIONAIS" spreadsheets). Run once against an existing database:
#
#   bin/rails providers:seed
#   bin/rails providers:seed RAILS_ENV=production
#
# Re-running is safe: records are matched by [provider_type, name] and created
# only when missing, so it never duplicates existing providers.
#
# Notes:
# - `document` is left blank: the source files carry no CNPJ/CPF. The column is
#   NOT NULL but the model allows a blank document, so an empty string is used.
# - `phone_number` keeps the real number when the source provided one; otherwise
#   a clearly-fake placeholder is used so the record is valid and the manager can
#   backfill it later.

namespace :providers do
  desc "Seed real suppliers extracted from the event managers' files (idempotent)"
  task seed: :environment do
    placeholder_phone = "(00) 00000-0000"

    # Each entry: [provider_type, name, contact_name, phone_number]
    # contact_name falls back to the business name when no person was named.
    providers = [
      # --- photographers (FOTO) ---
      [ "photographer", "ILUMIT", "Michael Brito", placeholder_phone ],
      [ "photographer", "João Melo", "João Melo", placeholder_phone ],
      [ "photographer", "Magnum", "Magnum", placeholder_phone ],
      [ "photographer", "Magno", "Magno", placeholder_phone ],
      [ "photographer", "Esdras", "Esdras", placeholder_phone ],
      [ "photographer", "Story Maker", "Bia Maia", placeholder_phone ],
      [ "photographer", "Vitória Costa", "Vitória Costa", placeholder_phone ],
      [ "photographer", "David Carvalho", "David Carvalho", placeholder_phone ],
      [ "photographer", "Wallison Freitas", "Wallison Freitas", placeholder_phone ],
      [ "photographer", "Glauber Albuquerque", "Glauber Albuquerque", placeholder_phone ],
      [ "photographer", "Kelvin Duarte", "Kelvin Duarte", "85988220444" ],
      [ "photographer", "Reflect", "Bruna", placeholder_phone ],
      [ "photographer", "Michelle", "Michelle", "99452.1582" ],

      # --- filming (FILMAGEM / VÍDEO) ---
      [ "filming", "Farol Films", "Farol Films", placeholder_phone ],
      [ "filming", "Alisson Pimenta", "Alisson Pimenta", placeholder_phone ],
      [ "filming", "Kbum Filmes", "Kbum Filmes", placeholder_phone ],
      [ "filming", "Mira Films", "Mira Films", placeholder_phone ],
      [ "filming", "VH Films", "Vitor Hugo", "991104643" ],
      [ "filming", "Realize Memórias", "Realize Memórias", placeholder_phone ],
      [ "filming", "Alexandre Films", "Alexandre Films", placeholder_phone ],
      [ "filming", "Premier", "Premier", placeholder_phone ],
      [ "filming", "Gabi", "Gabi", placeholder_phone ],

      # --- decoration (DECORAÇÃO) ---
      [ "decoration", "Dayvid Decorações", "Dayvid", "98749.0597" ],
      [ "decoration", "Vitor Oliveira", "Vitor Oliveira", placeholder_phone ],
      [ "decoration", "Michelle Moura", "Michelle Moura", placeholder_phone ],
      [ "decoration", "Bloom Design Floral", "Gabriel", placeholder_phone ],
      [ "decoration", "Rejania Machado", "Rejania Machado", placeholder_phone ],
      [ "decoration", "Estúdio Viva", "Leandro", placeholder_phone ],
      [ "decoration", "Dito Machado", "Dito Machado", placeholder_phone ],
      [ "decoration", "Claudemir", "Claudemir", placeholder_phone ],
      [ "decoration", "Janaina Ersin", "Janaina Ersin", placeholder_phone ],
      [ "decoration", "Victor Teixeira", "Victor Teixeira", placeholder_phone ],
      [ "decoration", "Patrícia Aquino", "Patrícia Aquino", "99132.9002" ],
      [ "decoration", "Wilfrid", "Wilfrid", placeholder_phone ],
      [ "decoration", "Neide", "Neide", placeholder_phone ],

      # --- music (MÚSICA / DJ / BANDA / COREÓGRAFA) ---
      [ "music_band", "Quarteto Arcos", "Quarteto Arcos", placeholder_phone ],
      [ "music_band", "DJ Cirilo", "DJ Cirilo", placeholder_phone ],
      [ "music_band", "Banda Alt", "Banda Alt", placeholder_phone ],
      [ "music_band", "Juliet", "Juliet", placeholder_phone ],
      [ "music_band", "Diego Sena", "Diego Sena", placeholder_phone ],
      [ "music_band", "Karla Vieira", "Karla Vieira", placeholder_phone ],
      [ "music_band", "Ernesto Por Deus", "Ernesto Por Deus", "99732-0698" ],
      [ "music_band", "Philipe Dantas & Banda", "Philipe Dantas", placeholder_phone ],
      [ "music_band", "DJ Pedro Alencar", "DJ Pedro Alencar", placeholder_phone ],
      [ "music_band", "Paulo José", "Paulo José", placeholder_phone ],
      [ "music_band", "DJ Thiago Felipe", "DJ Thiago Felipe", placeholder_phone ],
      [ "music_band", "Benjamin e Banda", "Benjamin", placeholder_phone ],
      [ "music_band", "Yago Golveira", "Yago Golveira", placeholder_phone ],
      [ "music_band", "Maestro Poty e Banda", "Maestro Poty", placeholder_phone ],
      [ "music_band", "Humberto Araújo", "Humberto Araújo", placeholder_phone ],
      [ "music_band", "Amanda Mendes e Banda", "Amanda Mendes", "98791.3693" ],
      [ "music_band", "Marjorie Fernandes", "Marjorie Fernandes", "996660915" ],
      [ "music_band", "Carlos Magno", "Carlos Magno", placeholder_phone ],
      [ "music_band", "Polyana", "Polyana", placeholder_phone ],

      # --- light & structure (ILUMI & ESTRUT / GERADOR) ---
      [ "light", "Luz e Cia", "Luz e Cia", placeholder_phone ],
      [ "light", "Climatize", "Climatize", placeholder_phone ],
      [ "light", "RCE", "RCE", placeholder_phone ],
      [ "light", "Lumix", "Felipe", placeholder_phone ],
      [ "light", "Rental", "Rental", placeholder_phone ],
      [ "light", "RV Geradores", "Vitor", placeholder_phone ],
      [ "light", "Pedro Pinheiro", "Pedro Pinheiro", placeholder_phone ],

      # --- cake (BOLO) ---
      [ "cake", "Cake Mania", "Cake Mania", placeholder_phone ],
      [ "cake", "Katia Bolos", "Katia", placeholder_phone ],
      [ "cake", "Magnificake", "Magnificake", placeholder_phone ],
      [ "cake", "Fest Bolo", "Fest Bolo", placeholder_phone ],
      [ "cake", "Magda", "Magda", placeholder_phone ],
      [ "cake", "Analu", "Analu", placeholder_phone ],
      [ "cake", "Bom Bocado", "Bom Bocado", placeholder_phone ],

      # --- sweets (DOCES / BEM CASADOS / BROWNIES / SUSPIROS / CREPES / SORVETE) ---
      [ "sweets", "Antoniete", "Antoniete", placeholder_phone ],
      [ "sweets", "Célia Bezerra", "Célia Bezerra", placeholder_phone ],
      [ "sweets", "Doce Dom", "Doce Dom", "99112717" ],
      [ "sweets", "San Paolo", "San Paolo", placeholder_phone ],
      [ "sweets", "Quero Brownie", "Quero Brownie", placeholder_phone ],
      [ "sweets", "Emporio Brownie", "Emporio Brownie", placeholder_phone ],
      [ "sweets", "Doce Mel", "Doce Mel", placeholder_phone ],
      [ "sweets", "G&G Crepes", "G&G", "98938.4606" ],
      [ "sweets", "Fluffy Donuts", "Fluffy Donuts", placeholder_phone ],
      [ "sweets", "Ame Suspiros", "Ame Suspiros", placeholder_phone ],
      [ "sweets", "Tizziana", "Tizziana", placeholder_phone ],

      # --- chocolates (linha personalizada) ---
      [ "chocolates", "Cintia Lobo", "Cintia Lobo", placeholder_phone ],
      [ "chocolates", "Carol Chocolates", "Carol", placeholder_phone ],

      # --- drinks / coquetel (COQUETEL / BEBIDAS) ---
      [ "drinks", "One Two Drinks", "One Two Drinks", placeholder_phone ],
      [ "drinks", "Unique Experience", "Unique Experience", placeholder_phone ],
      [ "drinks", "Coktelitas", "Coktelitas", placeholder_phone ],

      # --- beer / chopp (CHOPP) ---
      [ "beer", "Dona do Chopp", "Renata", placeholder_phone ],

      # --- bouquet (BUQUÊ) ---
      [ "bouquet", "Josivânia Araújo", "Josivânia Araújo", placeholder_phone ],

      # --- beauty (CABELO E MAQUIAGEM) ---
      [ "beauty_shop", "Michelle Souza", "Michelle Souza", placeholder_phone ],
      [ "beauty_shop", "Beatriz Santiago", "Beatriz Santiago", placeholder_phone ],
      [ "beauty_shop", "Isadora Falcão", "Isadora Falcão", placeholder_phone ],
      [ "beauty_shop", "Grazy Monique", "Grazy Monique", placeholder_phone ],
      [ "beauty_shop", "Bella Salon", "Jane", placeholder_phone ],
      [ "beauty_shop", "Mateus Petrovick", "Mateus Petrovick", placeholder_phone ],

      # --- women_cloth (ROUPA NOIVA / VESTIDO ANIVERSARIANTE) ---
      [ "women_cloth", "Dressa", "Dressa", placeholder_phone ],
      [ "women_cloth", "Unique Maison", "Unique Maison", placeholder_phone ],
      [ "women_cloth", "Studio Nai", "Studio Nai", placeholder_phone ],
      [ "women_cloth", "Cris Pontes Ateliê", "Cris Pontes", placeholder_phone ],
      [ "women_cloth", "Tulip Ateliê", "Tulip Ateliê", placeholder_phone ],
      [ "women_cloth", "Rendá", "Rendá", placeholder_phone ],

      # --- men_cloth (ROUPA NOIVO) ---
      [ "men_cloth", "Brooksfield", "Brooksfield", placeholder_phone ],

      # --- souvenir (LEMBRANÇA) ---
      [ "souvenir", "Stampa Manix", "Stampa Manix", placeholder_phone ],
      [ "souvenir", "Aviarte", "Aviarte", placeholder_phone ],

      # --- invitations (CONVITES) ---
      [ "invitations", "Amo Convites", "Amo Convites", placeholder_phone ],
      [ "invitations", "Fazendo Arte", "Fazendo Arte", placeholder_phone ],
      [ "invitations", "Studio Grão", "Studio Grão", placeholder_phone ],
      [ "invitations", "Roccia Atelie", "Roccia Atelie", placeholder_phone ]
    ]

    created = 0
    providers.each do |provider_type, name, contact_name, phone_number|
      record = Provider.find_or_create_by!(provider_type: provider_type, name: name) do |p|
        p.contact_name = contact_name
        p.phone_number = phone_number
        p.document = ""
      end
      created += 1 if record.previously_new_record?
    end

    puts "Fornecedores no seed: #{providers.size}"
    puts "Criados agora: #{created} (já existentes: #{providers.size - created})"
    puts "Total de fornecedores no banco: #{Provider.count}"
  end
end
