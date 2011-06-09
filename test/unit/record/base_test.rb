require File.join(File.dirname(__FILE__), '../../test_helper.rb')

class RecordBaseTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @contact = @client.Contact.build(:name => 'Test Contact Name ABC')
  end
  
  context "base record" do
    
    should "create new model instance from #new_model_class" do
      model_class = @contact.new_model_class("Invoice")
      assert_kind_of(Xeroizer::Record::InvoiceModel, model_class)
      assert_equal(@contact.parent.application, model_class.application)
      assert_equal('Invoice', model_class.model_name)
    end
    
    should "new_record? should be new on create" do
      assert_equal(true, @contact.new_record?)
    end
  
  end
  
  context "new_record? states" do
  
    should "new_record? should be false when loading data" do
      Xeroizer::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_record_xml(:contact), :code => '200'))
      contact = @client.Contact.find('TESTID')
      assert_kind_of(Xeroizer::Record::Contact, contact)
      assert_equal(false, contact.new_record?)
    end
    
    should "new_record? should be false after successfully creating a record" do 
      Xeroizer::OAuth.any_instance.stubs(:put).returns(stub(:plain_body => get_record_xml(:contact), :code => '200'))
      assert_equal(true, @contact.new_record?)
      assert_nil(@contact.contact_id)
      assert_equal(true, @contact.save, "Error saving contact: #{@contact.errors.inspect}")
      assert_equal(false, @contact.new_record?)
      assert(@contact.contact_id =~ GUID_REGEX, "@contact.contact_id is not a GUID, it is '#{@contact.contact_id}'")
    end
    
    should "new_record? should be false if we have specified a primary key" do
      contact = @client.Contact.build(:contact_id => 'ABC')
      assert_equal(false, contact.new_record?)
      
      contact = @client.Contact.build(:contact_number => 'CDE')
      assert_equal(true, contact.new_record?)
      
      contact = @client.Contact.build(:name => 'TEST NAME')
      assert_equal(true, contact.new_record?)
    end
    
  end
  
end