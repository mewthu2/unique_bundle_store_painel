class ProductPreparation < ApplicationRecord
  # Callbacks
  after_commit :resolve_stock
  # Associacoes
  belongs_to :product
  # Validacoes

  # Escopos

  # Metodos estaticos
  # Metodos publicos

  def resolve_stock
    product.update(resolver_stock: product.resolver_stock - quantity)
  end
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
