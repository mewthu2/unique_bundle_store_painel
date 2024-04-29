class ProductSale < ApplicationRecord
  # Callbacks
  enum kind: [:seven_days, :thirty_days]
  # Associacoes
  belongs_to :product
  # Validacoes
  validates :product_id, uniqueness: { scope: [:kind, :month_refference, :year_refference, :week_refference], message: 'Já existe um dado de venda deste tipo para este produto neste período.' }
  # Escopos

  # Metodos estaticos
  # Metodos publicos
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
