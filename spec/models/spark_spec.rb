# == Schema Information
#
# Table name: sparks
#
#  id                :integer          not null, primary key
#  content_type      :string(1)
#  content           :text
#  content_hash      :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  file_file_name    :string(255)
#  file_content_type :string(255)
#  file_file_size    :integer
#  file_updated_at   :datetime
#

require 'spec_helper'

describe Spark, :type => :model do
  
  before do
    @attr = {
      :content_type => "L",
      :content      => "http://google.com/",
      :file         => Rack::Test::UploadedFile.new('spec/fixtures/images/test.jpg', 'image/jpeg')
    }
  end
  
  it "creates a new instance given valid attributes" do
    Spark.create!(@attr)
  end
  
  describe "validation" do
    
    it "requires a content type" do
      spark = Spark.new(@attr)
      spark.content_type = ""
      expect(spark).not_to be_valid
    end
    
    it "accepts valid content types" do
      types = %w[L V C T P A]
      types.each do |t|
        spark = Spark.new(@attr.merge(:content_type => t))
        expect(spark).to be_valid
      end
    end
    
    it "rejects invalid content types" do
      types = %w[l v c t p a v W w I i some_type whatever]
      types.each do |t|
        spark = Spark.new(@attr.merge(:content_type => t))
        expect(spark).not_to be_valid
      end
    end
    
    it "requires content" do
      spark = Spark.new(@attr)
      spark.content = ""
      expect(spark).not_to be_valid
    end
    
  end
  
  describe "content hash" do
    
    it "hashes content after saving" do
      spark = Spark.new(@attr)
      spark.save
      
      expect(spark.content_hash).not_to be_blank
    end
    
    it "requires a unique hash" do
      spark = Spark.new(@attr)
      spark.save
      
      spark2 = Spark.new(@attr)
      spark2.spark_type = "P"
      expect(spark2).not_to be_valid
    end
    
  end
  
  describe "file" do
    
    it "has a file attribute" do
      expect(Spark.new).to respond_to(:file)
    end
    
    describe "without an attached file" do
      
      before do
        @attr[:file] = nil
        @spark = Spark.create(@attr)
      end
      
      it "has a missing url" do
        expect(@spark.file.url).to eq("/files/original/missing.png")
      end
      
    end
    
    describe "with an attached file" do
      
      before do
        @spark = Spark.create(@attr)
      end
      
      it "has a valid url" do
        expect(@spark.file.url).not_to eq("/files/original/missing.png")
      end
      
    end
    
  end
  
  describe "idea association" do
    
    before do
      @spark = Spark.create(@attr)
      
      @i1 = FactoryGirl.create(:idea)
      @i2 = FactoryGirl.create(:idea)
      
      @i1.sparks << @spark
      @i2.sparks << @spark
    end
    
    it "has a ideas attribute" do
      expect(@spark).to respond_to(:ideas)
    end
    
    it "has the right ideas" do
      expect(@spark.ideas).to eq([@i1, @i2])
    end
    
    it "doesn't destroy associated ideas" do
      @spark.destroy
      [@i1, @i2].each do |i|
        expect(Idea.find_by(id: i.id)).not_to be_nil
      end
    end
    
  end
  
  describe "user association" do
    
    before do
      @spark = Spark.create(@attr)
      
      @u1 = FactoryGirl.create(:user)
      @u2 = FactoryGirl.create(:user)
      
      @u1.sparks << @spark
      @u2.sparks << @spark
    end
    
    it "has a users attribute" do
      expect(@spark).to respond_to(:users)
    end
    
    it "has the right users" do
      expect(@spark.users).to eq([@u1, @u2])
    end
    
    it "doesn't destroy associated users" do
      @spark.destroy
      [@u1, @u2].each do |u|
        expect(User.find_by(id: u.id)).not_to be_nil
      end
    end
    
  end
  
  describe "comment association" do
    
    before do
      @spark = Spark.create(@attr)
      
      @user = FactoryGirl.create(:user)
      
      @c1 = FactoryGirl.create(:comment)
      @c2 = FactoryGirl.create(:comment)
      
      @c1.user = @user
      @c2.user = @user
      
      @c1.commentable = @spark
      @c2.commentable = @spark
      
      @c1.save
      @c2.save
    end
    
    it "has an comments attribute" do
      expect(@spark).to respond_to(:comments)
    end
    
    it "has the right comments" do
      expect(@spark.comments).to eq([@c1, @c2])
    end
    
    it "does destroy associated comments" do
      @spark.destroy
      [@c1, @c2].each do |c|
        expect(Comment.find_by(id: c.id)).to be_nil
      end
    end
    
  end
  
  describe "tag association" do
    
    before do
      @spark = FactoryGirl.create(:spark)
      
      @t1 = FactoryGirl.create(:tag)
      @t2 = FactoryGirl.create(:tag)
      
      @t1.sparks << @spark
      @t2.sparks << @spark
    end
    
    it "has a tags attribute" do
      expect(@spark).to respond_to(:tags)
    end
    
    it "has the right tags" do
      expect(@spark.tags).to eq([@t1, @t2])
    end
    
    it "doesn't destroy associated tags" do
      @spark.destroy
      [@t1, @t2].each do |t|
        expect(Tag.find_by(id: t.id)).not_to be_nil
      end
    end
    
  end
  
  describe "random" do
    
    before do
      10.times do
        FactoryGirl.create(:spark)
      end
    end
    
    it "should randomize the sparks" do
      expect(Spark.random(0.4).map(&:id)).not_to eq(Spark.all.map(&:id))
    end
    
    it "should return the same order for the same seed" do
      expect(Spark.random(0.4).map(&:id)).to eq(Spark.random(0.4).map(&:id))
      expect(Spark.random(0.3).map(&:id)).to eq(Spark.random(0.3).map(&:id))
      expect(Spark.random(0.3).map(&:id)).not_to eq(Spark.random(0.4).map(&:id))
    end
    
  end
  
end
