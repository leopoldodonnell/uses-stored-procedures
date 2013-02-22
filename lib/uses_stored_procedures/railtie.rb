require 'active_record/railtie'
require 'active_support/core_ext'

module UsesStoredProcedures
  class Railtie < Rails::Railtie
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.send :include, UsesStoredProcedures
    end
  end
end