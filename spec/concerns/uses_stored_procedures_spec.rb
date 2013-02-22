require File.expand_path('../../spec_helper', __FILE__)
require 'uses_stored_procedures'

describe "UsesStoredProceduresSpec" do
  before(:all) do
    
    proc_sql = <<END
    CREATE PROCEDURE `test_proc` ()
    BEGIN
        SELECT * FROM people;
    END;
END

    proc_with_params = <<END
    CREATE PROCEDURE `people_by_name_and_zip` (IN in_name VARCHAR(255), IN zip INTEGER)
    BEGIN
        SELECT * FROM people WHERE name like in_name and zip_code = zip;
    END;
END
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS people")
    ActiveRecord::Base.connection.execute("DROP PROCEDURE IF EXISTS test_proc")
    ActiveRecord::Base.connection.execute("DROP PROCEDURE IF EXISTS people_by_name_and_zip")
    
    ActiveRecord::Base.connection.create_table(:people) do |t|
        t.string  :name
        t.integer :zip_code
        t.string  :foo
        t.string  :bar
    end
    ActiveRecord::Base.connection.execute(proc_sql)
    ActiveRecord::Base.connection.execute(proc_with_params)

    class Foo
      include UsesStoredProcedures
      uses_stored_proc :test_proc      
    end

    class Person < ActiveRecord::Base
    end
    
    t1 = Person.create :foo => 'foo', :bar => 'bar', :name => 'Samual', :zip_code => 02101
    t1.save
  end
  
  after(:all) do
    ActiveRecord::Base.connection.execute("DROP PROCEDURE IF EXISTS test_proc")
    ActiveRecord::Base.connection.execute("DROP TABLE IF EXISTS tracks_active_records")
    ActiveRecord::Base.connection.execute("DROP PROCEDURE IF EXISTS people_by_name_and_zip")
  end
  
  it "is mixed into an ActiveRecord::Base class" do
    ActiveRecord::Base.should respond_to :uses_stored_proc
  end

  it "enables stored procedures to be called on a derived class of ActiveRecord::Base Class" do
    class Person < ActiveRecord::Base
    end
    
    Person.uses_stored_proc :test_proc
    Person.test_proc.should_not be nil
  end
  
  it "enables stored procedures to be called on an instance of an ActiveRecord:Bass" do
    class Person < ActiveRecord::Base
    end
    
    Person.uses_stored_proc :test_proc
    t = Person.new
    t.test_proc.should_not be nil
  end
  
  it "enables stored procedures to be called on classes not derived from ActiveRecord::Base" do
    f = Foo.new
    r = f.test_proc.should_not be nil
  end
  
  it "responds from a stored procedure with an array of Hash who's members respond to getters and setters" do
    f = Foo.new
    r = f.test_proc
    item = r[0]
    item.keys { |k| item.should respond_to k.to_sym }
  end
  
  it "responds from a stored procedure with an array of Hash who's members can be get or set by method name" do
    f = Foo.new
    r = f.test_proc
    value = r[0].foo = 'banana'
    value.should == 'banana'
    r[0].foo.should == 'banana'
  end
  
  it "enables stored procedues to be called with ruby parameters" do
    Person.uses_stored_proc :people_by_name_and_zip
    r = Person.people_by_name_and_zip("%am%", 02101)
    r.length.should_not == 0
  end
  
  it "enables stored procudures to respond with an array that is mapped by a block as part of its definition" do
    Person.uses_stored_proc :people_by_name_and_zip do |item| Person.new item end
    r = Person.people_by_name_and_zip("%am%", 02101)
    r[0].class.should be Person
  end

  it "enables stored procudures to respond with an array that is mapped to an instance method as part of its definition" do
    class MyService
      include UsesStoredProcedures
      uses_stored_proc :find_people, :proc_name => 'people_by_name_and_zip', :filter => :map_people
      
      def self.map_people(item)
        Person.new item
      end
    end
    
    r = MyService.find_people("%am%", 02101)
    r[0].class.should be Person
  end

end
