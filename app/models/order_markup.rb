class OrderMarkup < ApplicationRecord
  # Callbacks
  enum status: [:pending, :concluded]
  # Associacoes
  # Validacoes

  # Escopos

  # Metodos estaticos
  # Metodos publicos

  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
