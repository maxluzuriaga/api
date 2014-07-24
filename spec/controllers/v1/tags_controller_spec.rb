require 'spec_helper'

describe V1::TagsController, :type => :controller do
  
  describe "GET 'index'" do
    
    before do
      @tags = []
      
      5.times do
        @tags << FactoryGirl.create(:tag)
      end
    end
    
    it "is successful" do
      get :index, :format => 'json', :token => @auth_token
      expect(response).to be_success
    end
    
    it "returns the correct tags" do
      get :index, :format => 'json', :token => @auth_token
      output = JSON.parse(response.body)
      
      expect(output).to be_a_kind_of(Array)
      expect(output.length).to eq(@tags.length)
      
      output.each_with_index do |tag, index|
        expect(tag["tag_text"]).to eq(@tags[index].tag_text)
      end
    end
    
  end
  
  describe "GET 'show'" do
    
    before do
      @tag = FactoryGirl.create(:tag)
    end
    
    it "is successful" do
      get :show, :id => @tag.tag_text, :format => 'json', :token => @auth_token
      expect(response).to be_success
    end
    
    it "returns the correct tag" do
      get :show, :id => @tag.tag_text, :format => 'json', :token => @auth_token
      output = JSON.parse(response.body)
      
      expect(output).to be_a_kind_of(Hash)
      expect(output["tag_text"]).to eq(@tag.tag_text)
      expect(output["jawns"]).to be_a_kind_of(Array)
    end
    
  end
  
end
