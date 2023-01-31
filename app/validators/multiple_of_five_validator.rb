class MultipleOfFiveValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, "is not a multiple of 5") unless value % 5 == 0
  end
end
