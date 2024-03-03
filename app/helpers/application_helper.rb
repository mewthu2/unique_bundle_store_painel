module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

  def formatar_data(data_string)
    data = DateTime.parse(data_string)

    dia_semana = data.strftime('%A')
    mes = data.strftime('%B')
    ano = data.year

    "#{dia_semana}, #{mes} #{data.day}, #{ano}"
  end

  def horas_ou_dias_atras(data)
    data_time = DateTime.parse(data)

    diferenca_em_horas = ((Time.now - data_time) / 3600).round

    if diferenca_em_horas < 24
      "#{diferenca_em_horas} hours ago"
    else

      dias_atras = (Time.now.to_date - data_time.to_date).to_i
      "#{dias_atras} days ago"
    end
  end
end
