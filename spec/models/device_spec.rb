# == Schema Information
#
# Table name: devices
#
#  id              :integer          not null, primary key
#  token           :string(255)
#  registration_id :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  user_id         :integer
#

require 'spec_helper'

describe Device, :type => :model do
  before do
    @user = FactoryGirl.create(:user)
    @attr = {
      :user_id          => @user.id,
      :registration_id  => "xxxxxxxx",
    }
  end
  
  it "creates a new instance given valid attributes" do
    Device.create!(@attr)
  end
  
  describe "token" do
    
    it "generates a new token on create" do
      device = Device.create!(@attr)
      expect(device.token).not_to be_nil
    end
    
    it "generates unique tokens" do
      expect(Device.create!(@attr).token).not_to eq(Device.create!(@attr).token)
    end
    
  end
  
  describe "user association" do
    
    before do
      @device = Device.create(@attr)
      
      @user = FactoryGirl.create(:user)
            
      @user.devices << @device
    end
    
    it "has a user attribute" do
      expect(@device).to respond_to(:user)
    end
    
    it "has the right user" do
      expect(@device.user).to eq(@user)
    end
    
    it "doesn't destroy associated users" do
      @device.destroy
      expect(User.find_by(id: @user.id)).not_to be_nil
    end
    
  end
  
end
