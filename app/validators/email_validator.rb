class EmailValidator < ActiveModel::EachValidator
  POPULAR_PROVIDERS = %w[
    gmail
    yahoo
    icloud
    outlook
    mac
    hotmail
  ].freeze

  BAD_TLD_VARIATIONS = %w[
    comn
    con
    cmo
    cmon
    cnom
  ].freeze

  def validate_each(record, attribute, value)
    unless value.present? && value.match?(URI::MailTo::EMAIL_REGEXP)
      record.errors.add(attribute, (options[:message] || "is invalid"))
      return
    end

    domain_parts = value.split("@")&.last
    if domain_parts.blank?
      record.errors.add(attribute, (options[:message] || "is invalid"))
      return
    end

    domain_tld = domain_parts.split(".")
    if domain_tld.blank?
      record.errors.add(attribute, (options[:message] || "is invalid"))
      return
    end

    return unless POPULAR_PROVIDERS.include?(domain_tld.first)

    if BAD_TLD_VARIATIONS.include?(domain_tld.last)
      record.errors.add(attribute, (options[:message] || "is invalid"))
    end
  end
end
