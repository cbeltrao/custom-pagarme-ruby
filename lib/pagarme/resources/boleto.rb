module PagarMe
  class Boleto < Model
    attr_accessor :bank, :instructions, :due_at, :document_number, :type

    PAGARME_BANK_CODE = 198.freeze
    VALID_TYPE = 'DM'.freeze

    VALIDATION_RULES = {
      instructions: ->(value) { value && value.length <= 256 },
      due_at: ->(value) { value },
      type: ->(value) { value && value == VALID_TYPE },
      document_number: ->(value) { value && value.is_a?(String) },
      bank: ->(value) { value == PAGARME_BANK_CODE },
    }.freeze

    def initialize(params = {})
    if params.present?
      params[:type]     = VALID_TYPE
      params[:bank]     = PAGARME_BANK_CODE
      params[:document] = format_document_number(params[:document])
    end

    @instructions     = params[:instructions]
    @due_at           = params[:due_at]
    @type             = params[:type]
    @document_number  = params[:document]
    @bank             = params[:bank]

    validate! unless params.blank?

    super
    end

    private
    def format_document_number(document_number)
      formatted_document_number = document_number.gsub(/\D/, '')
    end

    # TODO: Refactor to use ActiveModel::Validations
    def validate!
      VALIDATION_RULES.each do |attribute, validation_rule|
        value = send(attribute)
        raise "#{attribute} inválido: #{value}" unless validation_rule.call(value)
      end
    end
  end
end