require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Slot" do

  before(:each) do
    @store = setup_default_store
    @document = Document.new
    @slot = Slot.new(@document)
  end
  
  it "should store arbitrary value" do
    @slot.value = "some value"
    @slot.value.should == "some value"
  end

  it "should store arbitrary value" do
    @slot.value = "some value"
    @slot.value.should == "some value"
  end

  it "should preserve Ruby object for a complex value" do
    @slot.value = ["some value"]
    @slot.value.object_id.should == @slot.value.object_id
  end
  
  it "should store VersionedDocument reference if value is a saved Document" do
    some_doc = Document.create!(:something => 1)
    some_doc.save!
    @slot.value = some_doc
    @slot.value.should == some_doc
    @slot.to_raw.should match(/@##{UUID_RE}.#{VERSION_RE}/)
  end

  it "should store VersionedDocument reference if value is a VersionedDocument" do
    some_doc = Document.new(:something => 1)
    some_doc.extend(VersionedDocument)
    some_doc.save!
    @slot.value = some_doc
    @slot.value.should == some_doc
    @slot.to_raw.should match(/@##{UUID_RE}.#{VERSION_RE}/)
  end

  it "should store Document reference if value is a saved Document" do
    some_doc = Document.new
    @slot.value = some_doc
    @slot.value.should == some_doc
    @slot.to_raw.should match(/@##{UUID_RE}/)
  end
  
end

describe "Slot that directly references document" do
  
  before(:each) do
    setup_default_store
    @another_doc = Document.create! :some_data => "1"
    @doc = Document.create! :another_doc => @another_doc
  end
  
  it "should load the same Ruby object each time" do
    doc = @doc.reload
    doc_obj = doc.another_doc
    doc.another_doc.object_id.should == doc_obj.object_id
  end
  
end

describe "Slot that indirectly references document" do
  
  before(:each) do
    setup_default_store
    @another_doc = Document.create! :some_data => "1"
    @doc = Document.create! :another_docs => [@another_doc]
  end
  
  it "should load the same Ruby object each time" do
    doc = @doc.reload
    doc_obj = doc.another_docs.first
    doc.another_docs.first.object_id.should == doc_obj.object_id
  end
  
end