# Register the xlsx mime type so controllers can respond_to format.xlsx.
Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx
