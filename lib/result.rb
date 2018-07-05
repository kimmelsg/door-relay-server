#
# Simple result object.
#
class Result
  def self.success(message: nil, payload: nil)
    result = create_result
    result.new(success?: true, message: message, payload: payload)
  end

  def self.failure(message: nil)
    result = create_result
    result.new(success?: false, message: message, payload: false)
  end

  private_class_method def self.create_result
    Struct.new(:success?, :message, :payload, keyword_init: true)
  end
end
