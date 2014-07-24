# == Schema Information
#
# Table name: ideas
#
#  id          :integer          not null, primary key
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer
#

require 'spec_helper'

describe Idea, :type => :model do
  
  before do
    @attr = {
      :description  => "This is an idea"
    }
  end
  
  it "creates a new instance given valid attributes" do
    Idea.create!(@attr)
  end
  
  describe "spark association" do
    
    before do
      @idea = Idea.create(@attr)
      
      @s1 = FactoryGirl.create(:spark)
      @s2 = FactoryGirl.create(:spark)
      
      @s1.ideas << @idea
      @s2.ideas << @idea
    end
    
    it "has a sparks attribute" do
      expect(@idea).to respond_to(:sparks)
    end
    
    it "has the right sparks" do
      expect(@idea.sparks).to eq([@s1, @s2])
    end
    
    it "doesn't destroy associated sparks" do
      @idea.destroy
      [@s1, @s2].each do |s|
        expect(Spark.find_by(id: s.id)).not_to be_nil
      end
    end
    
  end
  
  describe "user association" do
    
    before do
      @idea = Idea.create(@attr)
      
      @user = FactoryGirl.create(:user)
            
      @user.ideas << @idea
    end
    
    it "has a user attribute" do
      expect(@idea).to respond_to(:user)
    end
    
    it "has the right user" do
      expect(@idea.user).to eq(@user)
    end
    
    it "doesn't destroy associated users" do
      @idea.destroy
      expect(User.find_by(id: @user.id)).not_to be_nil
    end
    
  end
  
  describe "comment association" do
    
    before do
      @idea = Idea.create(@attr)
      
      @user = FactoryGirl.create(:user)
      
      @c1 = FactoryGirl.create(:comment)
      @c2 = FactoryGirl.create(:comment)
      
      @c1.user = @user
      @c2.user = @user
      
      @c1.commentable = @idea
      @c2.commentable = @idea
      
      @c1.save
      @c2.save
    end
    
    it "has an comments attribute" do
      expect(@idea).to respond_to(:comments)
    end
    
    it "has the right comments" do
      expect(@idea.comments).to eq([@c1, @c2])
    end
    
    it "does destroy associated comments" do
      @idea.destroy
      [@c1, @c2].each do |c|
        expect(Comment.find_by(id: c.id)).to be_nil
      end
    end
    
  end
  
  describe "tag association" do
    
    before do
      @idea = FactoryGirl.create(:idea)
      
      @t1 = FactoryGirl.create(:tag)
      @t2 = FactoryGirl.create(:tag)
      
      @t1.ideas << @idea
      @t2.ideas << @idea
    end
    
    it "has a tags attribute" do
      expect(@idea).to respond_to(:tags)
    end
    
    it "has the right tags" do
      expect(@idea.tags).to eq([@t1, @t2])
    end
    
    it "doesn't destroy associated tags" do
      @idea.destroy
      [@t1, @t2].each do |t|
        expect(Tag.find_by(id: t.id)).not_to be_nil
      end
    end
    
  end
  
  describe "random" do
    
    before do
      10.times do
        FactoryGirl.create(:idea)
      end
    end
    
    it "should randomize the ideas" do
      expect(Idea.random(0.4).map(&:id)).not_to eq(Idea.all.map(&:id))
    end
    
    it "should return the same order for the same seed" do
      expect(Idea.random(0.4).map(&:id)).to eq(Idea.random(0.4).map(&:id))
      expect(Idea.random(0.3).map(&:id)).to eq(Idea.random(0.3).map(&:id))
      expect(Idea.random(0.3).map(&:id)).not_to eq(Idea.random(0.4).map(&:id))
    end
    
  end
  
end
