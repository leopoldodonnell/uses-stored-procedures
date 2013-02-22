require 'active_record'

ActiveRecord::Base.establish_connection(
    :adapter  => 'mysql2',
    :database => 'test',
    :username => '',
    :password => '',
    :host     => 'localhost'
)

RSpec.configure do |config|
  config.order = "random"
end
