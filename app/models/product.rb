class Product < ApplicationRecord
  # Callbacks
  # Associacoes
  has_one :product_preparation
  # Validacoes

  # Escopos

  add_scope :by_active do |value|
    if value.present?
      case value
      when 'Todos'
        all
      when 'sim'
        where(status: 'Active')
      when 'nao'
        where.not(status: 'Active')
      end
    end
  end

  add_scope :by_fulfillment_channel do |value|
    if value.present?
      if value == 'Todos'
        all
      else
        where(fulfillment_channel: value)
      end
    end
  end

  add_scope :by_status do |value|
    if value.present?
      case value
      when 'positivo'
        where('resolver_stock < ?', 0)
      when 'negativo'
        where('resolver_stock >= ?', 0)
      when 'Todos'
        all
      end
    end
  end

  add_scope :search do |value|
    if value.present?
      where('products.seller_sku LIKE :valor OR
            products.asin1 LIKE :valor OR
            products.listing_id LIKE :valor OR
            products.id_product LIKE :valor OR
            products.item_name LIKE :valor OR
            products.item_description LIKE :valor OR
            products.id LIKE :valor', valor: "#{value}%")
    end
  end
  # Metodos estaticos
  # Metodos publicos
  # Metodos GET
  # Metodos SET

  # Nota: os metodos somente utilizados em callbacks ou utilizados somente por essa
  #       propria classe deverao ser privados (remover essa anotacao)
end
