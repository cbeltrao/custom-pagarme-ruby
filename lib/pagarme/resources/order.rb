module PagarMe
  class Order < Model
    attr_accessor :customer, :items, :payments

    # TODO: Add more validations
    VALIDATION_RULES = {
      customer: ->(value) { value && value.is_a?(PagarMe::Customer) },
    }.freeze

    def initialize(params = {})
      @customer = params[:customer]
      @items = params[:items]
      @payments = params[:payments]

      validate! unless params.empty?

      super
    end

    def transaction_charge
      if self['charges'].present?
        self['charges'].first['last_transaction']
      else
        nil
      end
    end

    def transaction_charge_succeeded?
      if transaction_charge.present?
        transaction_charge['status'] == 'generated' && transaction_charge['success'] == true
      else
        false
      end
    end

    private
    def validate!
      VALIDATION_RULES.each do |attribute, validation_rule|
        value = send(attribute)
        raise "#{attribute} inválido: #{value}" unless validation_rule.call(value)
      end
    end
  end
end
