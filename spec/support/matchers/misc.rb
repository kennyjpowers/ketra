# Matcher to see if a string is a URL or not
RSpec::Matchers.define :be_url do |expected|
  match do |actual|
    # Use the URL library to parse the string, returning false if this fails
    URI.parse(actual) rescue false
  end
end
