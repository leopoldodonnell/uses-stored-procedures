require 'uses_stored_procedures/hash_with_attributes'

module UsesStoredProcedures
  extend ActiveSupport::Concern
  
  module ClassMethods
    def uses_stored_proc(name, *args, &block)
      options   = args.extract_options!
      proc_name = options[:proc_name] || name.to_s

      # Install variables dynamically to avoid adding it
      # to ALL instances of ActiveRecord::Base
      if ! self.respond_to?(:stored_proc_block)
        class_attribute :stored_proc_block
        class_attribute :proc_names
        self.stored_proc_block = {}
        self.proc_names = {}
      end
      
      # Install the class and instance methods
      self.proc_names[name] = proc_name
      define_method name do |*args| self.class.exec_stored_proc(proc_names[__method__], args) end
      singleton_class = class << self; self; end
      singleton_class.send(:define_method, name) do |*args| 
        exec_stored_proc(proc_names[__method__], args) 
      end
      
      # Install the row mapper block or method
      if block_given?      
        self.stored_proc_block[proc_name] = block
      elsif options[:filter]
        self.stored_proc_block[proc_name] = options[:filter]
      end
    end    

    def exec_stored_proc(name, args)
      sql = "call #{name} (" + args.map {|a| "'#{a}'"}.join(',') + ")"

      records = ActiveRecord::Base.connection.select_all(sql)
      ActiveRecord::Base.connection.reconnect!

      case stored_proc_block[name]
        when Symbol
          # Map with a member function
          records.map do |r| self.send(stored_proc_block[name].to_s, HashWithAttributes.new.merge(r)) end
        when Proc
          # Map with a block
          records.map do |r| stored_proc_block[name].call(HashWithAttributes.new.merge(r)) end
        else
          # Just map it 
          records.map do |r| HashWithAttributes.new.merge r end
      end
    end
  end
end

require 'uses_stored_procedures/railtie'

