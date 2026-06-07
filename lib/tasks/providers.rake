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
      [ "invitations", "Roccia Atelie", "Roccia Atelie", placeholder_phone ],

      # === Second batch — extracted from "CASAMENTOS 2025" event files ===

      # --- photographers (FOTO) ---
      [ "photographer", "Junior Alves", "Junior Alves", placeholder_phone ],
      [ "photographer", "Roberio Castro", "Roberio Castro", placeholder_phone ],
      [ "photographer", "Foto Metrar", "Foto Metrar", placeholder_phone ],
      [ "photographer", "Tiago Guedes", "Tiago Guedes", placeholder_phone ],
      [ "photographer", "Fabio Meireles", "Fabio Meireles", placeholder_phone ],
      [ "photographer", "Beco da Imagem", "Beco da Imagem", placeholder_phone ],
      [ "photographer", "David Marques", "David Marques", placeholder_phone ],
      [ "photographer", "Rodrigo e Duda", "Rodrigo e Duda", "991512445" ],
      [ "photographer", "Lucas Spidler", "Lucas Spidler", placeholder_phone ],
      [ "photographer", "Depois do Click", "Depois do Click", "99981-6767" ],
      [ "photographer", "Sara Feiosa", "Sara Feiosa", placeholder_phone ],
      [ "photographer", "Cleonice e Giovana", "Cleonice e Giovana", placeholder_phone ],
      [ "photographer", "Clécio Albuquerque", "Clécio Albuquerque", placeholder_phone ],
      [ "photographer", "David", "David", placeholder_phone ],
      [ "photographer", "Studio MWillians", "Studio MWillians", placeholder_phone ],
      [ "photographer", "Eduardo", "Eduardo", placeholder_phone ],
      [ "photographer", "Kreatos", "Kreatos", placeholder_phone ],
      [ "photographer", "Reflab", "Reflab", placeholder_phone ],

      # --- filming (FILMAGEM / VÍDEO) ---
      [ "filming", "Simão Amora", "Simão Amora", placeholder_phone ],
      [ "filming", "Italo Rodrigues", "Italo Rodrigues", placeholder_phone ],
      [ "filming", "Jardim Filmes", "Jardim Filmes", "997685186" ],
      [ "filming", "Victor Rocha", "Victor Rocha", "99775.3796" ],
      [ "filming", "Alisson dos Santos", "Alisson dos Santos", "986524405" ],
      [ "filming", "Cartier Films", "Cartier Films", placeholder_phone ],
      [ "filming", "DN Filmes", "Danilo Sousa", placeholder_phone ],
      [ "filming", "Samuel Souza", "Samuel Souza", placeholder_phone ],
      [ "filming", "Disraele", "Disraele", placeholder_phone ],
      [ "filming", "Ville Video", "Ville Video", placeholder_phone ],

      # --- decoration (DECORAÇÃO) ---
      [ "decoration", "Wilfrid Decorações", "Wilfrid", placeholder_phone ],
      [ "decoration", "Jacqueline Kato", "Jacqueline Kato", placeholder_phone ],
      [ "decoration", "Leandro", "Leandro", placeholder_phone ],
      [ "decoration", "Mundo da Lua Decorações", "Mundo da Lua Decorações", placeholder_phone ],
      [ "decoration", "Rochele", "Rochele", "997881881" ],
      [ "decoration", "Adelaide", "Adelaide", placeholder_phone ],
      [ "decoration", "Maria Clara", "Maria Clara", placeholder_phone ],
      [ "decoration", "Gabriel Camara", "Gabriel Camara", placeholder_phone ],
      [ "decoration", "Patricia Lopes", "Patricia Lopes", "85988556596" ],
      [ "decoration", "Nascimento Junior", "Nascimento Junior", placeholder_phone ],
      [ "decoration", "Regina", "Regina", placeholder_phone ],
      [ "decoration", "Branca Mourão", "Branca Mourão", placeholder_phone ],
      [ "decoration", "Roberta Freire", "Roberta Freire", placeholder_phone ],
      [ "decoration", "Kaio Wendel", "Kaio Wendel", "989450176" ],
      [ "decoration", "Isabela Mindelo", "Isabela Mindelo", placeholder_phone ],
      [ "decoration", "Breno", "Breno", placeholder_phone ],
      [ "decoration", "Paulo Folhagem", "Paulo Folhagem", placeholder_phone ],

      # --- music (MÚSICA / DJ / BANDA) ---
      [ "music_band", "Nayra Monte", "Nayra Monte", placeholder_phone ],
      [ "music_band", "Karla Tomé", "Karla Tomé", placeholder_phone ],
      [ "music_band", "Daniel Barros", "Daniel Barros", placeholder_phone ],
      [ "music_band", "Mazé e Zelia Santhi", "Mazé e Zelia Santhi", placeholder_phone ],
      [ "music_band", "Laio Cosmo", "Laio Cosmo", "985783464" ],
      [ "music_band", "Elane Araújo", "Elane Araújo", placeholder_phone ],
      [ "music_band", "Balanço Social", "Balanço Social", placeholder_phone ],
      [ "music_band", "Cecilia Yohanna", "Cecilia Yohanna", placeholder_phone ],
      [ "music_band", "DJ Marciano", "DJ Marciano", placeholder_phone ],
      [ "music_band", "Juliana Barreto", "Juliana Barreto", placeholder_phone ],
      [ "music_band", "Juliana Oliveira e Banda", "Juliana Oliveira", placeholder_phone ],
      [ "music_band", "Levizim", "Levizim", placeholder_phone ],
      [ "music_band", "Bia Melandes", "Bia Melandes", placeholder_phone ],
      [ "music_band", "Vivian Fernandes", "Vivian Fernandes", placeholder_phone ],
      [ "music_band", "Bella Vox", "Bella Vox", placeholder_phone ],
      [ "music_band", "Sandrinha", "Sandrinha", placeholder_phone ],
      [ "music_band", "Nagib e Coral", "Nagib", placeholder_phone ],
      [ "music_band", "Davi Cartaxo", "Davi Cartaxo", placeholder_phone ],
      [ "music_band", "Mix Brasil", "Mix Brasil", placeholder_phone ],
      [ "music_band", "Banda Versare", "Banda Versare", placeholder_phone ],
      [ "music_band", "Iza Façanha", "Iza Façanha", placeholder_phone ],
      [ "music_band", "Giovanni Barruti", "Giovanni Barruti", "991392294" ],
      [ "music_band", "DJ Davi Fernandes", "DJ Davi Fernandes", placeholder_phone ],
      [ "music_band", "Forró Mix", "Forró Mix", placeholder_phone ],
      [ "music_band", "Celebratrio", "Celebratrio", placeholder_phone ],
      [ "music_band", "Luan Melo e Banda", "Luan Melo", placeholder_phone ],
      [ "music_band", "DJ Pedro Barbosa", "DJ Pedro Barbosa", placeholder_phone ],
      [ "music_band", "Gilmario", "Gilmario", placeholder_phone ],
      [ "music_band", "Rondinele", "Rondinele", placeholder_phone ],

      # --- light & structure (ILUMI & ESTRUT / GERADOR) ---
      [ "light", "DB Geradores", "DB Geradores", "99507897" ],
      [ "light", "TL Eventos", "TL Eventos", placeholder_phone ],
      [ "light", "CSI Geradores", "CSI", placeholder_phone ],
      [ "light", "Plejart", "Plejart", "991382544" ],
      [ "light", "JT Eventos", "Jorginho", placeholder_phone ],
      [ "light", "Amplifica", "Amplifica", placeholder_phone ],
      [ "light", "Espaço Tuning", "Espaço Tuning", placeholder_phone ],
      [ "light", "Val Cenário", "Val Cenário", placeholder_phone ],
      [ "light", "FG Refrigerações", "FG Refrigerações", placeholder_phone ],
      [ "light", "Nordeste Gerador", "Nordeste Gerador", placeholder_phone ],
      [ "light", "Marson", "Marson", placeholder_phone ],
      [ "light", "Treelight Eventos", "Treelight Eventos", placeholder_phone ],
      [ "light", "Luminarte", "Luminarte", placeholder_phone ],
      [ "light", "Staff Soluções", "Solon", "986030805" ],
      [ "light", "Ponto Alto Produções", "Ponto Alto Produções", placeholder_phone ],
      [ "light", "Fulltime", "Fulltime", placeholder_phone ],
      [ "light", "Fernando Iluminação", "Fernando", placeholder_phone ],

      # --- cake (BOLO) ---
      [ "cake", "Nabirra", "Nabirra", placeholder_phone ],
      [ "cake", "Mayar", "Mayar", placeholder_phone ],
      [ "cake", "Wladia", "Wladia", placeholder_phone ],
      [ "cake", "Cacau2You", "Cacau2You", placeholder_phone ],
      [ "cake", "Bolcher", "Bolcher", placeholder_phone ],
      [ "cake", "Miriam Pontes", "Miriam Pontes", placeholder_phone ],
      [ "cake", "Magic Candy", "Magic Candy", placeholder_phone ],

      # --- sweets (DOCES / BEM CASADOS / BROWNIES) ---
      [ "sweets", "Dilazaro", "Dilazaro", "98531.6458" ],
      [ "sweets", "Choco Brownie", "Choco Brownie", placeholder_phone ],
      [ "sweets", "Carla Soares", "Carla Soares", placeholder_phone ],
      [ "sweets", "Sweet Marie", "Sweet Marie", placeholder_phone ],
      [ "sweets", "Tia Marcia", "Tia Marcia", placeholder_phone ],
      [ "sweets", "Bossa Macarons", "Bossa", placeholder_phone ],
      [ "sweets", "Empório Di Doce", "Empório Di Doce", placeholder_phone ],
      [ "sweets", "My Coco", "My Coco", placeholder_phone ],
      [ "sweets", "Petit Gelato", "Petit Gelato", placeholder_phone ],
      [ "sweets", "50 Sabores", "50 Sabores", placeholder_phone ],
      [ "sweets", "Glaucilene", "Glaucilene", placeholder_phone ],
      [ "sweets", "Prima Luana", "Prima Luana", placeholder_phone ],
      [ "sweets", "Din Din Gourmet", "Din Din Gourmet", placeholder_phone ],

      # --- drinks / coquetel (COQUETEL) ---
      [ "drinks", "Mago dos Drinks", "Mago dos Drinks", placeholder_phone ],
      [ "drinks", "Drinkeria", "Cassia", "9860861828" ],
      [ "drinks", "Cokteria", "Cokteria", placeholder_phone ],
      [ "drinks", "Pequiar Drink", "Pequiar Drink", placeholder_phone ],

      # --- beer / chopp (CHOPP) ---
      [ "beer", "Chopp to Go", "Chopp to Go", placeholder_phone ],
      [ "beer", "Chopp do Lira", "Chopp do Lira", placeholder_phone ],
      [ "beer", "Rede Express", "Rede Express", placeholder_phone ],

      # --- buffet (BUFFET especializado) ---
      [ "buffet", "Palatium Buffet", "Luciana Monteiro", placeholder_phone ],
      [ "buffet", "Bouganville Buffet", "Bouganville Buffet", placeholder_phone ],
      [ "buffet", "Sottili Buffet", "Weber", placeholder_phone ],
      [ "buffet", "Drinkteria", "Drinkteria", placeholder_phone ],

      # --- bouquet (BUQUÊ) ---
      [ "bouquet", "Sousas Floricultura", "Sousas Floricultura", placeholder_phone ],

      # --- beauty (CABELO E MAQUIAGEM) ---
      [ "beauty_shop", "Lays Brunelli", "Lays Brunelli", placeholder_phone ],
      [ "beauty_shop", "Jessica Eufrasio", "Jessica Eufrasio", placeholder_phone ],
      [ "beauty_shop", "Eduardo Alves", "Eduardo Alves", placeholder_phone ],
      [ "beauty_shop", "Grazy Lourenço", "Grazy Lourenço", placeholder_phone ],
      [ "beauty_shop", "Emanuelle Lima", "Emanuelle Lima", "998407215" ],
      [ "beauty_shop", "Lu Servesion", "Lu Servesion", placeholder_phone ],
      [ "beauty_shop", "Mariana Holanda", "Mariana Holanda", "98212-2434" ],
      [ "beauty_shop", "Leidiane Oliveira", "Leidiane Oliveira", "99778-0373" ],
      [ "beauty_shop", "Ticiana Maquiagem", "Ticiana", placeholder_phone ],
      [ "beauty_shop", "Andressa Guerra", "Andressa Guerra", placeholder_phone ],
      [ "beauty_shop", "Rebeca Rodrigues", "Rebeca Rodrigues", "99718-3644" ],
      [ "beauty_shop", "Dudu Ferreira", "Dudu Ferreira", placeholder_phone ],
      [ "beauty_shop", "Backstreet Barbearia", "Backstreet", placeholder_phone ],

      # --- women_cloth (ROUPA NOIVA / DAMAS) ---
      [ "women_cloth", "Ivanildo Nunes", "Ivanildo Nunes", placeholder_phone ],
      [ "women_cloth", "Prin Ateliê", "Prin Ateliê", placeholder_phone ],
      [ "women_cloth", "Ticiana Sampaio", "Ticiana Sampaio", placeholder_phone ],
      [ "women_cloth", "Nai Bridal", "Nai Bridal", placeholder_phone ],
      [ "women_cloth", "Maison Cris", "Maison Cris", placeholder_phone ],
      [ "women_cloth", "Maison Vip", "Maison Vip", placeholder_phone ],
      [ "women_cloth", "Ateliê Renata Oliveira", "Renata Oliveira", placeholder_phone ],
      [ "women_cloth", "Solange Sahado", "Solange Sahado", placeholder_phone ],
      [ "women_cloth", "Lisblu", "Lisblu", placeholder_phone ],
      [ "women_cloth", "Nobre Elegancy", "Nobre Elegancy", placeholder_phone ],
      [ "women_cloth", "Bel Robes", "Bel Robes", placeholder_phone ],

      # --- men_cloth (ROUPA NOIVO) ---
      [ "men_cloth", "Nai Man", "Nai Man", placeholder_phone ],
      [ "men_cloth", "Bal Reis", "Bal Reis", placeholder_phone ],
      [ "men_cloth", "Studio Men", "Studio Men", placeholder_phone ],
      [ "men_cloth", "Via Veneto", "Via Veneto", placeholder_phone ],

      # --- souvenir (LEMBRANÇA / FOTO LEMBRANÇA) ---
      [ "souvenir", "Click Selfie", "Click Selfie", "99609-5899" ],
      [ "souvenir", "Mãos Mágicas Embalagens", "Mãos Mágicas Embalagens", placeholder_phone ],
      [ "souvenir", "Themis", "Themis", placeholder_phone ],
      [ "souvenir", "Studio Eventos", "Studio Eventos", placeholder_phone ],

      # --- invitations (CONVITES / MENUS) ---
      [ "invitations", "Caixa e Cia", "Caixa e Cia", placeholder_phone ],
      [ "invitations", "Brasil Convites", "Brasil Convites", placeholder_phone ],
      [ "invitations", "SC Convites", "SC Convites", placeholder_phone ]
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
