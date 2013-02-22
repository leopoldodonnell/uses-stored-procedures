require 'uses_stored_procedures/hash_with_attributes'

##
# UsesStoredProcedures provides that ability to extend a class with
# the ability to call stored_procedures providing an array of hash
# entries that can be mapped to an array of other objects.
#
module UsesStoredProcedures
  extend ActiveSupport::Concern
  
  module ClassMethods
    ##
    # Add a stored procedure that can ba called on a class or a
    # class instance.
    #
    # @param [Symbol] name is the symbolic name of the method to be created.
    # By default, it is assumed that the stored procedure has the same
    # name as a string.
    #
    # @param args is a variable list of optional arguments. Available Options
    # include:
    #
    #   * :proc_name - is the name of the stored procedure. Use this if the
    #   name doesn't match the name paramter
    #   * :filter - is a class method used to filter the return results. The
    #   method should take a HashWithAttributes instance and return an object
    #   for the array entry
    #
    # @param [Proc] block - is a block that takes a HashWithAttributes instance 
    # and returns an object for the array entry.
    #
    # @raises if the current SQL adapter isn't supported.
    #
    
    def uses_stored_proc(name, *args, &block)
      options   = args.extract_options!
      proc_name = options[:proc_name] || name.to_s
      
      self.init_class_attributes()
      self.install_stored_proc_methods(name, proc_name)
            
      # Install the row mapper block or method
      if block_given?      
        self.stored_proc_block[proc_name] = block
      elsif options[:filter]
        self.stored_proc_block[proc_name] = options[:filter]
      end
    end    

    # Install variables dynamically to avoid adding it
    # to ALL instances of ActiveRecord::Base
    #
    # :stored_proc_block is a hash that either contains a block or
    # the symbolic name of the method to call to filter results
    #
    # :proc_names is a hash where keys are the method names to call
    # and the values are the actual stored procedure names
    # 
    def init_class_attributes() #:nodoc:
      return if self.respond_to?(:stored_proc_block)
      class_attribute :stored_proc_block
      class_attribute :proc_names
      class_attribute :call_proc
      self.stored_proc_block = {}
      self.proc_names = {}

      case ActiveRecord::Base.connection.adapter_name.to_sym
      when :Mysql2, :MySQL
        self.call_proc = 'call'
      when :PostgreSQL
        self.call_proc = 'select'
      when :SQLServer
        self.call_proc = 'exec'
      else
        raise "uses_stored_procedurs does not support your connection adapter"
      end
        
    end
    
    # Define the class and instance methods. Note the need to
    # create a singleton class instance to create the stored
    # procedure.
    def install_stored_proc_methods(name, proc_name) #:nodoc:
      self.proc_names[name] = proc_name
      define_method name do |*args| self.class.exec_stored_proc(proc_names[__method__], args) end
      singleton_class = class << self; self; end
      singleton_class.send(:define_method, name) do |*args| 
        exec_stored_proc(proc_names[__method__], args) 
      end
    end
    
    # Run the stored procedure with the arguments provided and send
    # them through a filter method or block if specified.
    def exec_stored_proc(name, args) #:nodoc:
      sql = "#{call_proc} #{name} (" + args.map {|a| "'#{a}'"}.join(',') + ")"

      # Call the stored procedure. Note the need to reset the connection
      # because the mysql connection tends to hangup when stored procedures
      # are called. Note that testing for ::connected? doesn't work.
      #
      # TODO: investigate why stored procedures cause connection hangups.
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

