require 'active_record'

ActiveRecord::Base.establish_connection(
    :adapter  => "sqlite3",
    :database => "spec/db/db_test.sqlite"
)

RSpec.configure do |config|
  config.order = "random"
end
