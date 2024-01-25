class Product < ApplicationRecord
  # Callbacks
  # Associacoes

  # Validacoes

  # Escopos

  add_scope :by_fulfillment_channel do |value|
    where(fulfillment_channel: value) if value.present?
  end
  add_scope :by_status do |value|
    case value
    when 'positive'
      where('resolver_stock < ?', 0)
    when 'negative'
      where('resolver_stock >= ?', 0)
    end
  end

  add_scope :see_rules do |value|
    where(status: 'Active') unless value.present?
  end

  add_scope :search do |value|
    where('products.seller_sku LIKE :valor OR
           products.asin1 LIKE :valor OR
           products.listing_id LIKE :valor OR
           products.id_product LIKE :valor OR
           products.item_name LIKE :valor OR
           products.item_description LIKE :valor OR
           products.id LIKE :valor', valor: "#{value}%")
  end
  # Metodos estaticos
  # Metodos publicos
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
