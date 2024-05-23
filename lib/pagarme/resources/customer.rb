module PagarMe
  class Customer < Model
    attr_accessor :name, :email, :document, :document_type, :type

    VALID_DOCUMENT_TYPES  = %w[ CPF CNPJ ].freeze
    VALID_TYPES           = %w[ individual company ].freeze

    VALIDATION_RULES = {
      name: ->(value) { value && value.is_a?(String) },
      email: ->(value) { value && value.is_a?(String) },
      document: ->(value) { value && value.is_a?(String) && (value.length == 14 || value.length == 11) },
      document_type: ->(value) { VALID_DOCUMENT_TYPES.include?(value) },
      type: ->(value) { value && VALID_TYPES.include?(value) }
    }.freeze


    def initialize(params = {})
      if params.present?
        params[:document]       = format_document_number(params[:document])
        params[:document_type]  = identify_document_type(params[:document])
        params[:type]           = identify_customer_type(params[:document], params[:document_type])
      end

      @name           = params[:name]
      @email          = params[:email]
      @document       = params[:document]
      @document_type  = params[:document_type]
      @type           = params[:type]

      validate! unless params.blank?

      super
    end

    private
    def format_document_number(document_number)
      return if document_number.blank?

      formatted_document_number = document_number.gsub(/\D/, '')

      formatted_document_number
    end

    def identify_document_type(document_number)
      return if document_number.blank?

      cpf_length  = 11
      cnpj_length = 14

      document_type =
        case document_number.length
          when cpf_length then 'CPF'
          when cnpj_length then 'CNPJ'
        end
    end

    def identify_customer_type(document, document_type)
      return if document.blank? || document_type.blank?

      type =
        case document_type
          when 'CPF' then 'individual'
          when 'CNPJ' then 'company'
        end
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