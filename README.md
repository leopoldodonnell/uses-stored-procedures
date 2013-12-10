[![Build Status](https://travis-ci.org/leopoldodonnell/uses-stored-procedures.png?branch=master)](https://travis-ci.org/leopoldodonnell/uses-stored-procedures)
[![Dependency Status](https://gemnasium.com/leopoldodonnell/uses-stored-procedures.png)](https://gemnasium.com/leopoldodonnell/uses-stored-procedures)
[![Code Climate](https://codeclimate.com/github/leopoldodonnell/uses-stored-procedures.png)](https://codeclimate.com/github/leopoldodonnell/uses-stored-procedures)
[![Gem Version](https://fury-badge.herokuapp.com/rb/uses-store-procedures.png)](http://badge.fury.io/rb/uses-store-procedures)

# UsesStoredProcedures

Extends ActiveRecord with the ability to use SQL Stored Procedures in Rails.

So, you really need to use stored procedures in your Rails application. This gem extends ActiveRecord with a class method to add to your models or services. Sure stored procedures are *not the Rails way* they are an occasional project necessity. Your reasons may stem from a need to integrate with a legacy database with built-in business rules, or a need to improve performance where other avenues have been exhausted (given available project time). If you need this, *you know who you are*, I don't need to tell you why.

## Version

0.1.0

## Requirements

### Ruby

- 1.8.7, 1.9

### Rails

- 3.1.x or 3.2.x

### ORM

- ActiveRecord
- Mysql2, MySQL (Tested/Passing)
- SQLServer     (Untested, but should work)
- PostgreSQL    (Untested, unsure - please try it and notify the author)

## Installation

The current state of this gem is tested with MySQL, but it also does detection of SQLServer and PostgreSQL which will
be tested when time permits. Please contact the author if you've gotten it to work before this happens.

In your Gemfile

    gem 'uses-stored-procedures'

Or from the git repo for the bleeding edge (*feel free to star it :-)*)

    gem 'uses-stored-procedures', git => "git://github.com/leopoldodonnell/uses-stored-procedures"

Then from your project root:

    > bundle

To generate the documentation and view it, continue from the project root, then:

    > yard
    > yard server

## Using uses_stored_procedures to call stored procedures from Rails

**UsesStoredProcedues** extends ActiveRecord::Base with the single class method that takes the name of the procedure as a symbol, and optional parameters to generate a class and instance method that can be called to run the stored procedure.

Here's a simple example:

```ruby
class MyClass < ActiveRecord::Base
  uses_stored_proc :get_office_by_country {|row| "#{row.country} #{row.city}, phone: #{row.phone}"}
end
```

Which generates:

```ruby
def self.get_office_by_country(*args, &block)
  # code
end

def get_office_by_country(*args, &block)
  self.class.get_offic_by_country(args, block)
end
```   

So later you can do the following:
  
```ruby
result = MyClass.get_office_by_country 'Canada'
result.each {|item| puts item}
```

Note that the object passed to the block is a *UsesStoredProcedures#HashWithAttributes* instance that provides accessors for all of its keys.

### Syntax

The method signature for *uses_stored_proc* is:

```ruby
def self.uses_stored_proc(method_name, *options, &block)
```

That then generates a class and instance method named *method_name*.

* method_name - is the symbolic name of the stored procedure and is the name given to the generated class and instance methods. By default, the stored procedure that is called will be a stringified version of this method_name. Use the :proc_name option if the method_name won't be matching actual stored procedure name.

* options - is an array of arguments that are provided as *:arg_name => value* and where the last argument may be a block, or method name.

####Options

* proc_name - if the stored procedure name is different than method_name parameter, provide a string that matches the actual stored procedure name.

* filter - the name of a class method that receives an instance of *UsesStoredProcedures#HashWithAttributes* to map returned rows.

* block - make the last parameter a block that receive an instance of *UsesStoredProcedures#HashWithAttributes* to map returned rows.

#### Generated Methods

The generated methods all take a variable number of parameters that are mapped to the stored procedure call and can also take a block that can be used to map the returned rows. By default the returned value will be an array of values that are either instances of *UsesStoredProcedures#HashWithAttributes*, or mapped by the block. Note that passing a block overrides the block or method provided when calling *#uses_stored_proc*

### Another Example

```ruby
require 'uses_stored_procedures'

class ClientServices
  include UsesStoredProcedures

  uses_stored_proc :list_inactive_clients, :proc_name => 'GET_CLIENTS_INACTIVE_STATUS', :filter => :make_clients

  def self.make_clients(item)
    Client.new item
  end
end

client_services = ClientServices.new

# ...

client_list = client_services.list_inactive_clients(first_of_year)

# and so on ...
```

### License

MIT License. Copyright 2013 Leopold O'Donnell


