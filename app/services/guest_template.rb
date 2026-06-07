# Builds the sample .xlsx used to guide guest imports (admin + public).
class GuestTemplate
  CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet".freeze
  FILENAME = "modelo_convidados.xlsx".freeze

  def self.xlsx
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "Convidados") do |sheet|
      header = sheet.styles.add_style(b: true, bg_color: "EEEEEE", border: { style: :thin, color: "BBBBBB" })
      sheet.add_row [ "Nome", "Quantidade de convidados", "Tipo", "Telefone", "Observações" ], style: header
      sheet.add_row [ "João Silva", 2, "Adulto", "(85) 99999-0000", "" ]
      sheet.add_row [ "Maria Souza", 1, "Adulto", "(85) 98888-0000", "Mesa 3" ]
      sheet.add_row [ "Lucas Souza", 1, "Criança", "", "" ]
      sheet.column_widths 28, 22, 12, 20, 24
    end
    package.to_stream.read
  end
end
