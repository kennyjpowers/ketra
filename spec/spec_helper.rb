$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |f| require f }
require 'ketra'
