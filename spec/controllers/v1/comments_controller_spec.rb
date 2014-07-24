require 'spec_helper'

describe V1::CommentsController, :type => :controller do
  
  before do
    @spark = FactoryGirl.create(:spark)
    @idea = FactoryGirl.create(:idea)
  end
  
  describe "GET 'index'" do
    
    before do
      @spark_comments = []
      @idea_comments = []
      
      20.times do
        comment = FactoryGirl.create(:comment)
        comment.user = @test_user
        
        if [true, false].sample
          comment.commentable = @spark
          @spark_comments << comment
        else
          comment.commentable = @idea
          @idea_comments << comment
        end
        
        comment.save
      end
    end
    
    describe "on Sparks" do
      
      it "is successful" do
        get :index, :spark_id => @spark, :format => 'json', :token => @auth_token
        expect(response).to be_success
      end

      it "returns the correct comments" do
        get :index, :spark_id => @spark, :format => 'json', :token => @auth_token
        output = JSON.parse(response.body)

        expect(output).to be_a_kind_of(Array)
        expect(output.length).to eq(@spark.comments.length)

        output.each_with_index do |comment, index|
          expect(comment["comment_text"]).to eq(@spark.comments[index].comment_text)
        end
      end
      
    end
    
    describe "on Ideas" do
      
      it "is successful" do
        get :index, :idea_id => @idea, :format => 'json', :token => @auth_token
        expect(response).to be_success
      end

      it "returns the correct comments" do
        get :index, :idea_id => @idea, :format => 'json', :token => @auth_token
        output = JSON.parse(response.body)

        expect(output).to be_a_kind_of(Array)
        expect(output.length).to eq(@idea.comments.length)

        output.each_with_index do |comment, index|
          expect(comment["comment_text"]).to eq(@idea.comments[index].comment_text)
        end
      end
      
    end
    
  end
  
  describe "GET 'show'" do
    
    before do
      @spark_comment = FactoryGirl.create(:comment)
      @spark_comment.user = @test_user
      @spark_comment.commentable = @spark
      
      @spark_comment.save
      
      @idea_comment = FactoryGirl.create(:comment)
      @idea_comment.user = @test_user
      @idea_comment.commentable = @idea
      
      @idea_comment.save
    end
    
    describe "on a Spark" do
      
      it "is successful" do
        get :show, :spark_id => @spark, :id => @spark_comment, :format => 'json', :token => @auth_token
        expect(response).to be_success
      end

      it "returns the correct comment" do
        get :show, :spark_id => @spark, :id => @spark_comment, :format => 'json', :token => @auth_token
        output = JSON.parse(response.body)

        expect(output).to be_a_kind_of(Hash)
        expect(output["comment_text"]).to eq(@spark_comment.comment_text)
      end
      
    end
    
    describe "on an Idea" do
      
      it "is successful" do
        get :show, :idea_id => @idea, :id => @idea_comment, :format => 'json', :token => @auth_token
        expect(response).to be_success
      end

      it "returns the correct comment" do
        get :show, :idea_id => @idea, :id => @idea_comment, :format => 'json', :token => @auth_token
        output = JSON.parse(response.body)

        expect(output).to be_a_kind_of(Hash)
        expect(output["comment_text"]).to eq(@idea_comment.comment_text)
      end
      
    end
    
  end
  
  describe "POST 'create'" do
    
    before do
      @attr = {
        :comment_text => "This is a comment!"
      }
    end
    
    describe "on a Spark" do
      
      it "is successful" do
        post :create, :spark_id => @spark, :comment => @attr, :format => 'json', :token => @auth_token
        expect(response).to be_success
      end
    
      it "should create the comment" do
        expect {
          post :create, :spark_id => @spark, :comment => @attr, :format => 'json', :token => @auth_token
        }.to change { Comment.count }.by(1)
      end
      
      it "should return the comment" do
        post :create, :spark_id => @spark, :comment => @attr, :format => 'json', :token => @auth_token
        output = JSON.parse(response.body)

        expect(output).to be_a_kind_of(Hash)
        expect(output["comment_text"]).to eq(@attr[:comment_text])
      end
      
      it "should associate the user and the comment" do
        post :create, :spark_id => @spark, :comment => @attr, :format => 'json', :token => @auth_token
        comment = Comment.last
        expect(comment.user).to eq(@test_user)
      end
      
      it "should associate the spark and the comment" do
        post :create, :spark_id => @spark, :comment => @attr, :format => 'json', :token => @auth_token
        comment = Comment.find_by(comment_text: @attr[:comment_text])
        expect(comment.commentable).to eq(@spark)
      end
      
    end
    
    describe "on an Idea" do
      
      it "is successful" do
        post :create, :idea_id => @idea, :comment => @attr, :format => 'json', :token => @auth_token
        expect(response).to be_success
      end
    
      it "should create the comment" do
        expect {
          post :create, :idea_id => @idea, :comment => @attr, :format => 'json', :token => @auth_token
        }.to change { Comment.count }.by(1)
      end
      
      it "should return the comment" do
        post :create, :idea_id => @idea, :comment => @attr, :format => 'json', :token => @auth_token
        output = JSON.parse(response.body)

        expect(output).to be_a_kind_of(Hash)
        expect(output["comment_text"]).to eq(@attr[:comment_text])
      end
      
      it "should associate the user and the comment" do
        post :create, :idea_id => @idea, :comment => @attr, :format => 'json', :token => @auth_token
        comment = Comment.last
        expect(comment.user).to eq(@test_user)
      end
      
      it "should associate the idea and the comment" do
        post :create, :idea_id => @idea, :comment => @attr, :format => 'json', :token => @auth_token
        comment = Comment.last
        expect(comment.commentable).to eq(@idea)
      end
      
    end
    
  end
  
  describe "DELETE 'destroy'" do
    
    before do
      @comment = FactoryGirl.create(:comment)
      @comment.user = @test_user
      @comment.save
      
      @wrong_user = FactoryGirl.create(:user)
      @wrong_token = @wrong_user.devices.create(registration_id: "testid123").token
    end
    
    describe "on a Spark" do
      
      before do
        @comment.commentable = @spark
        @comment.save
      end
      
      describe "with the correct user" do
        
        it "is successful" do
          delete :destroy, :spark_id => @spark, :id => @comment, :format => 'json', :token => @auth_token
          expect(response).to be_success
        end

        it "destroys the comment" do
          expect {
            delete :destroy, :spark_id => @spark, :id => @comment, :format => 'json', :token => @auth_token
          }.to change { Comment.count }.by(-1)
        end
        
      end
      
      describe "with the wrong user" do
        
        it "isn't successful" do
          delete :destroy, :spark_id => @spark, :id => @comment, :format => 'json', :token => @wrong_token
          expect(response).not_to be_success
        end

        it "doesn't destroy the comment" do
          expect {
            delete :destroy, :spark_id => @spark, :id => @comment, :format => 'json', :token => @wrong_token
          }.not_to change { Comment.count }
        end
        
      end
      
    end
    
    describe "on an Idea" do
      
      before do
        @comment.commentable = @idea
        @comment.save
      end
      
      describe "with the correct user" do
        
        it "is successful" do
          delete :destroy, :idea_id => @idea, :id => @comment, :format => 'json', :token => @auth_token
          expect(response).to be_success
        end

        it "destroys the comment" do
          expect {
            delete :destroy, :idea_id => @idea, :id => @comment, :format => 'json', :token => @auth_token
          }.to change { Comment.count }.by(-1)
        end
        
      end
      
      describe "with the wrong user" do
        
        it "isn't successful" do
          delete :destroy, :idea_id => @idea, :id => @comment, :format => 'json', :token => @wrong_token
          expect(response).not_to be_success
        end

        it "doesn't destroy the comment" do
          expect {
            delete :destroy, :idea_id => @idea, :id => @comment, :format => 'json', :token => @wrong_token
          }.not_to change { Comment.count }
        end
        
      end
      
    end
    
  end
  
end
