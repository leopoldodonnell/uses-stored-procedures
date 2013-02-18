module UsesStoredProcedures
  extend ActiveSupport::Concern
  
  module ClassMethods
    def uses_stored_procedures
      include Internal
    end
  end
  
  module Internal
    extend ActiveSupport::Concern
    
    included do
    end
    
    module ClassMethods
    end
  end
  
end
