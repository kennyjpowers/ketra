RSpec::Matchers.define :have_configurable_field do |field|
  match do |object_instance|
    it_has_a_getter_and_setter = object_instance.respond_to?(field) &&
                                 object_instance.respond_to?("#{field}=")

    test = 1
    object_instance.send("#{field}=", test)

    it_returns_what_is_set = object_instance.send(field) == test

    #set it back to nil to not interfere with other tests
    object_instance.send("#{field}=", nil)
    it_has_a_getter_and_setter and it_returns_what_is_set
  end

  failure_message do |object_instance|
    "expected to be able to read and write #{field} on #{object_instance}"
  end

  failure_message_when_negated do |object_instance|
    "expected not to be able to read and write #{field} on #{object_instance}"
  end

  description do
    "have configurable #{field}"
  end
end

RSpec::Matchers.define :have_default do |field, default|
  match do |object_instance|
    object_instance.send(field).eql?(default)
  end
  
  failure_message do |object_instance|
    "expected #{field} to default to #{default} on #{object_instance}"
  end

  failure_message_when_negated do |object_instance|
    "expected #{field} to not default to #{default} on #{object_instance}"
  end

  description do
    "have #{default} as a default #{field}"
  end
end
