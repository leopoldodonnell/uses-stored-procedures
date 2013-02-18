require File.expand_path('../../spec_helper', __FILE__)
require 'uses_stored_procedures'

describe "UsesStoredProceduresSpec" do
  before(:all) do
  end
  
  after(:all) do
  end
  
  it "is mixed into an ActiveRecord::Base class" do
    ActiveRecord::Base.should respond_to :uses_stored_procedures
  end
  
end
