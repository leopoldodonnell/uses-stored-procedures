
module UsesStoredProcedures
  class StoredProcedure < ActiveRecord::Base
    
    do self.exec(name, *args)
      sp = self.new name, args
      sp.fetch
    end
    
    def initialize(name, *args)
      @proc_name = name
      @args = args.inject {|args, arg| args + ", '#{arg}'" }
    end
    
    def fetch
      
    end
  end
end