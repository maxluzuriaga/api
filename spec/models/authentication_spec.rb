# == Schema Information
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  provider   :string(255)
#  uid        :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Authentication, :type => :model do
  
  before do
    @attr = {
      :provider => "This is an idea",
      :uid      => "my@email.com"
    }
  end
  
  it "creates a new instance given valid attributes" do
    Authentication.create!(@attr)
  end
  
  describe "validation" do
    
    it "requires a provider" do
      auth = Authentication.new(@attr)
      auth.provider = ""
      expect(auth).not_to be_valid
    end
    
    it "requires a uid" do
      auth = Authentication.new(@attr)
      auth.uid = ""
      expect(auth).not_to be_valid
    end
    
  end
  
  describe "user association" do
    
    before do
      @auth = Authentication.create(@attr)
      
      @user = FactoryGirl.create(:user)
            
      @user.authentications << @auth
    end
    
    it "has a user attribute" do
      expect(@auth).to respond_to(:user)
    end
    
    it "has the right user" do
      expect(@auth.user).to eq(@user)
    end
    
    it "doesn't destroy associated users" do
      @auth.destroy
      expect(User.find_by(id: @user.id)).not_to be_nil
    end
    
  end
  
end
