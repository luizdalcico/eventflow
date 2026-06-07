module EventsHelper
  # [label, value] pairs for the home date filter select.
  # Values mirror Event::DATE_FILTERS; the blank value means "no date filter".
  def event_date_filter_options
    [
      [ "Todas as datas", "" ],
      [ "Essa semana", "this_week" ],
      [ "Esse mês", "this_month" ],
      [ "Próximo mês", "next_month" ],
      [ "Esse ano", "this_year" ],
      [ "Ano passado", "last_year" ],
      [ "Próximo ano", "next_year" ]
    ]
  end
end
