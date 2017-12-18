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

RSpec::Matchers.define :have_configurable_field_per_thread do |field|
  match do |object_instance|
    it_has_a_getter_and_setter = object_instance.respond_to?(field) &&
                                 object_instance.respond_to?("#{field}=")

    thread_1_value = 1
    thread_2_value = 2
    it_returns_what_is_set_in_the_first_thread = Thread.new do
      object_instance.send("#{field}=", thread_1_value)
      object_isntance.send(field) == thread_1_value
    end

    it_returns_what_is_set_in_the_second_thread = Thread.new do
      it_doesnt_return_what_was_set = object_instance.send(field) != thread_1_value
      object_instance.send("#{field}=", thread_2_value)
      object_isntance.send(field) == thread_2_value &&
        it_doesnt_return_what_was_set
    end

    it_returns_what_is_set = it_returns_what_is_set_in_the_first_thread &&
                             it_returns_what_is_set_in_the_second_thread

    #set it back to nil to not interfere with other tests
    object_instance.send("#{field}=", nil)
    it_has_a_getter_and_setter and it_returns_what_is_set
  end

  failure_message do |object_instance|
    "expected to be able to read and write #{field} on #{object_instance} per thread"
  end

  failure_message_when_negated do |object_instance|
    "expected not to be able to read and write #{field} on #{object_instance} per thread"
  end

  description do
    "have configurable #{field} per thread"
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

RSpec::Matchers.define :only_accept_valid_symbols_for do |field, values|
  match do |object_instance|
    values.each do |value|
      expect { object_instance.send("#{field}=", value) }.to_not raise_error
    end
    random_length = Random.new.rand(100)
    random_string = Random.new.bytes(random_length)
    random_sym = random_string.to_sym
    while(values.include? random_sym) do
      random_string = Random.new.bytes(random_length)
      random_sym = random_string.to_sym
    end
    expect{ object_instance.send("#{field}=", random_sym) }.to raise_error(ArgumentError)
  end

  failure_message do |object_instance|
    "expected #{field} to only accept #{values} on #{object_instance}"
  end

  failure_message_when_negated do |object_instance|
    "expected #{field} to not only accept #{values} on #{object_instance}"
  end

  description do
    "raise Argument Error if #{field} is set to anything other than #{values}"
  end
end
