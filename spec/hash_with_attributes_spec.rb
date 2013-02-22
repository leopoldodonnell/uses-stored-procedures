require File.expand_path('../spec_helper', __FILE__)
require 'uses_stored_procedures/hash_with_attributes'

describe "HashWithAttributesSpec" do
  sym_hash    = {:one => 1, :two => 2}
  string_hash = {'one' => 1, 'two' => 2}
  
  it "is a Hash that responds to methods named as keys to the hash where keys are strings" do
    h = UsesStoredProcedures::HashWithAttributes.new.merge string_hash
    h.keys.each do |k|
      h.should respond_to k
    end
  end

  it "is a Hash that responds to methods named as keys to the hash where keys are symbols" do
    h = UsesStoredProcedures::HashWithAttributes.new.merge sym_hash
    h.keys.each do |k|
      h.should respond_to k
    end
  end

  it "enables calling accessors for hash keys that are symbols" do
    h = UsesStoredProcedures::HashWithAttributes.new.merge string_hash
    (h.one = 3).should == 3
    h.one.should == 3
  end
  
  it "enables calling accessors for hash keys that are strings" do
    h = UsesStoredProcedures::HashWithAttributes.new.merge sym_hash
    (h.one = 3).should == 3
    h.one.should == 3
  end
end
