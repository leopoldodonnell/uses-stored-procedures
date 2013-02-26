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
      
      # Install the row mapper block or method
      self.install_stored_proc_methods(name, proc_name, call_stored_proc_verb, options[:filter] || block)
    end    


    # Return the SQL verb for calling a stored procedure.
    def call_stored_proc_verb()
      case ActiveRecord::Base.connection.adapter_name.to_sym
      when :Mysql2, :MySQL
        'call'
      when :PostgreSQL
        'select'
      when :SQLServer
        'exec'
      else
        raise "uses_stored_procedurs does not support your connection adapter"
      end        
    end
    
    # Define the class and instance methods. Note the need to
    # create a singleton class instance to create the stored
    # procedure class method.
    def install_stored_proc_methods(name, proc_name, call_stored_proc_verb, filter) #:nodoc:
      define_method name do |*args| 
        self.class.exec_stored_proc(proc_name, call_stored_proc_verb, filter, args) 
      end

      singleton_class = class << self; self; end
      singleton_class.send(:define_method, name) do |*args| 
        exec_stored_proc(proc_name, call_stored_proc_verb, filter, args) 
      end

    end
    
    # Run the stored procedure with the arguments provided and send
    # them through a filter method or block if specified.
    def exec_stored_proc(name, call_stored_proc_verb, filter, args) #:nodoc:
      sql = "#{call_stored_proc_verb} #{name} (" + args.map {|a| "'#{a}'"}.join(',') + ")"

      # Call the stored procedure. Note the need to reset the connection
      # because the mysql connection tends to hangup when stored procedures
      # are called. Note that testing for ::connected? doesn't work.
      #
      # TODO: investigate why stored procedures cause connection hangups.
      records = ActiveRecord::Base.connection.select_all(sql)
      ActiveRecord::Base.connection.reconnect!

      filter_stored_proc_results(records, filter)
    end

    private
      def filter_stored_proc_results(results, filter)
        case filter
          when Symbol
            # Map with a member function
            results.map do |r| self.send(filter.to_s, HashWithAttributes.new(r)) end
          when Proc
            # Map with a block
            results.map do |r| filter.call(HashWithAttributes.new(r)) end
          else
            # Just map it 
            results.map do |r| HashWithAttributes.new r end
        end
      end
    
  end
end

require 'uses_stored_procedures/railtie'

