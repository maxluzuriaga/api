require 'spec_helper'

describe V1::JawnsController, :type => :controller do
  
  before do
    @jawns = []
    @ideas = []
    @sparks = []
    
    20.times do
      if [true, false].sample
        idea = FactoryGirl.create(:idea)
        @jawns << idea
        @ideas << idea
      else
        spark = FactoryGirl.create(:spark)
        @jawns << spark
        @sparks << spark
      end
    end
    
    @jawns.reverse!
    @ideas.reverse!
    @sparks.reverse!
  end
  
  describe "GET 'index'" do
    
    it "is successful" do
      get :index, :format => 'json', :token => @auth_token
      expect(response).to be_success
    end
    
    it "returns the correct jawns" do
      get :index, :format => 'json', :token => @auth_token
      output = JSON.parse(response.body)
      
      expect(output).to be_a_kind_of(Array)
      expect(output.length).to eq(@jawns.length)
      
      output.each_with_index do |jawn, index|
        expect(jawn["jawn_type"]).to eq(@jawns[index].class.to_s.downcase)
      end
    end
    
    it "limits the jawns correctly" do
      get :index, :format => 'json', :limit => 10, :token => @auth_token
      output = JSON.parse(response.body)
      
      expect(output).to be_a_kind_of(Array)
      expect(output.length).to eq(10)
      
      output.each_with_index do |jawn, index|
        expect(jawn["jawn_type"]).to eq(@jawns[index].class.to_s.downcase)
      end
    end
    
    describe "offset" do
      
      it "returns the correct jawns" do
        get :index, :format => 'json', :offset => 5, :token => @auth_token
        output = JSON.parse(response.body)
        
        expect(output).to be_a_kind_of(Array)
        expect(output.length).to eq(@jawns.length - 5)
        
        jawns = @jawns[5..-1]
        
        output.each_with_index do |jawn, index|
          expect(jawn["jawn_type"]).to eq(jawns[index].class.to_s.downcase)
        end
      end
      
      it "limits the jawns correctly" do
        get :index, :format => 'json', :offset => 5, :limit => 10, :token => @auth_token
        output = JSON.parse(response.body)
        
        expect(output).to be_a_kind_of(Array)
        expect(output.length).to eq(10)
        
        jawns = @jawns[5..-1]
        
        output.each_with_index do |jawn, index|
          expect(jawn["jawn_type"]).to eq(jawns[index].class.to_s.downcase)
        end
      end
      
    end
    
    describe "lite response" do
      
      it "only returns ids and jawn_types" do
        get :index, :format => 'json', :lite => "true", :token => @auth_token
        output = JSON.parse(response.body)
        
        expect(output).to be_a_kind_of(Array)
        
        output.each do |jawn|
          expect(jawn["id"]).not_to be_nil
          expect(jawn["jawn_type"]).not_to be_nil
          expect(jawn["users"]).to be_nil
          expect(jawn["user"]).to be_nil
          expect(jawn["sparks"]).to be_nil
          expect(jawn["ideas"]).to be_nil
        end
      end
      
    end
    
    describe "random sorting" do
      
      it "returns the correct jawns" do
        seed = 0.3
        
        get :index, :format => 'json', :seed => "#{seed}", :token => @auth_token
        output = JSON.parse(response.body)

        expect(output).to be_a_kind_of(Array)
        expect(output.length).to eq(@jawns.length)
        
        jawns = (Spark.all + Idea.all).shuffle(random: Random.new((seed+1)*10000))
        
        output.each_with_index do |jawn, index|
          expect(jawn["jawn_type"]).to eq(jawns[index].class.to_s.downcase)
        end
      end
      
      it "returns the same jawns with the same seed" do
        seed = 0.3
        
        get :index, :format => 'json', :seed => "#{seed}", :token => @auth_token
        output = JSON.parse(response.body)
        
        get :index, :format => 'json', :seed => "#{seed}", :token => @auth_token
        output2 = JSON.parse(response.body)

        expect(output.length).to eq(output2.length)
        
        output.each_with_index do |jawn, index|
          expect(jawn["id"]).to eq(output2[index]["id"])
        end
      end
      
      describe "offset" do
        
        it "uses the same order as without the offset" do
          seed = 0.3

          get :index, :format => 'json', :seed => "#{seed}", :token => @auth_token
          output = JSON.parse(response.body)

          get :index, :format => 'json', :seed => "#{seed}", :token => @auth_token, :offset => 5
          output2 = JSON.parse(response.body)

          expect(output2.length).to eq(output.length - 5)

          output2.each_with_index do |jawn, index|
            expect(jawn["id"]).to eq(output[index + 5]["id"])
          end
        end
        
      end
      
    end
    
    describe "idea filtering" do
      
      it "filters ideas correctly" do
        get :index, :format => 'json', :filter => "ideas", :token => @auth_token
        output = JSON.parse(response.body)

        expect(output).to be_a_kind_of(Array)
        expect(output.length).to eq(@ideas.length)

        output.each_with_index do |jawn, index|
          expect(jawn["jawn_type"]).to eq("idea")
          expect(jawn["description"]).to eq(@ideas[index].description)
        end
      end
      
      it "filters ideas with a limit correctly" do
        get :index, :format => 'json', :filter => "ideas", :limit => 3, :token => @auth_token
        output = JSON.parse(response.body)

        expect(output).to be_a_kind_of(Array)
        expect(output.length).to eq(3)

        output.each_with_index do |jawn, index|
          expect(jawn["jawn_type"]).to eq("idea")
          expect(jawn["description"]).to eq(@ideas[index].description)
        end
      end
      
      describe "offset" do

        it "returns the correct jawns" do
          get :index, :format => 'json', :filter => "ideas", :offset => 3, :token => @auth_token
          output = JSON.parse(response.body)

          expect(output).to be_a_kind_of(Array)
          expect(output.length).to eq(@ideas.length - 3)

          jawns = @ideas[3..-1]

          output.each_with_index do |jawn, index|
            expect(jawn["jawn_type"]).to eq("idea")
            expect(jawn["description"]).to eq(jawns[index].description)
          end
        end

        it "limits the jawns correctly" do
          get :index, :format => 'json', :filter => "ideas", :offset => 3, :limit => 3, :token => @auth_token
          output = JSON.parse(response.body)

          expect(output).to be_a_kind_of(Array)
          expect(output.length).to eq(3)

          jawns = @ideas[3..-1]

          output.each_with_index do |jawn, index|
            expect(jawn["jawn_type"]).to eq("idea")
            expect(jawn["description"]).to eq(jawns[index].description)
          end
        end

      end
      
      describe "random sorting" do

        it "returns the correct ideas" do
          seed = 0.3

          get :index, :format => 'json', :filter => "ideas", :seed => "#{seed}", :token => @auth_token
          output = JSON.parse(response.body)

          expect(output).to be_a_kind_of(Array)
          expect(output.length).to eq(@ideas.length)
          
          idea_ids = @ideas.map(&:id)
          ids = []
          
          output.each do |jawn|
            ids << jawn["id"]
          end
          
          ids.each do |id|
            idea_ids.delete id
          end
          
          expect(idea_ids).to be_empty
        end
        
        it "returns the same ideas with the same seed" do
          seed = 0.3
        
          get :index, :format => 'json', :filter => "ideas", :seed => "#{seed}", :token => @auth_token
          output = JSON.parse(response.body)
        
          get :index, :format => 'json', :filter => "ideas", :seed => "#{seed}", :token => @auth_token
          output2 = JSON.parse(response.body)
        
          expect(output.length).to eq(output2.length)
        
          output.each_with_index do |jawn, index|
            expect(jawn["id"]).to eq(output2[index]["id"])
          end
        end
        
        describe "offset" do
        
          it "uses the same order as without the offset" do
            seed = 0.3
        
            get :index, :format => 'json', :filter => "ideas", :seed => "#{seed}", :token => @auth_token
            output = JSON.parse(response.body)
        
            get :index, :format => 'json', :filter => "ideas", :seed => "#{seed}", :token => @auth_token, :offset => 5
            output2 = JSON.parse(response.body)
        
            expect(output2.length).to eq(output.length - 5)
        
            output2.each_with_index do |jawn, index|
              expect(jawn["id"]).to eq(output[index + 5]["id"])
            end
          end
        
        end

      end
      
    end
    
    describe "spark filtering" do
      
      it "filters sparks correctly" do
        get :index, :format => 'json', :filter => "sparks", :token => @auth_token
        output = JSON.parse(response.body)

        expect(output).to be_a_kind_of(Array)
        expect(output.length).to eq(@sparks.length)

        output.each_with_index do |jawn, index|
          expect(jawn["jawn_type"]).to eq("spark")
          expect(jawn["content_hash"]).to eq(@sparks[index].content_hash)
        end
      end
      
      it "filters sparks with a limit correctly" do
        get :index, :format => 'json', :filter => "sparks", :limit => 3, :token => @auth_token
        output = JSON.parse(response.body)

        expect(output).to be_a_kind_of(Array)
        expect(output.length).to eq(3)

        output.each_with_index do |jawn, index|
          expect(jawn["jawn_type"]).to eq("spark")
          expect(jawn["content_hash"]).to eq(@sparks[index].content_hash)
        end
      end
      
      describe "offset" do

        it "returns the correct jawns" do
          get :index, :format => 'json', :filter => "sparks", :offset => 3, :token => @auth_token
          output = JSON.parse(response.body)

          expect(output).to be_a_kind_of(Array)
          expect(output.length).to eq(@sparks.length - 3)

          jawns = @sparks[3..-1]

          output.each_with_index do |jawn, index|
            expect(jawn["jawn_type"]).to eq("spark")
            expect(jawn["content_hash"]).to eq(jawns[index].content_hash)
          end
        end

        it "limits the jawns correctly" do
          get :index, :format => 'json', :filter => "sparks", :offset => 3, :limit => 3, :token => @auth_token
          output = JSON.parse(response.body)

          expect(output).to be_a_kind_of(Array)
          expect(output.length).to eq(3)

          jawns = @sparks[3..-1]

          output.each_with_index do |jawn, index|
            expect(jawn["jawn_type"]).to eq("spark")
            expect(jawn["content_hash"]).to eq(jawns[index].content_hash)
          end
        end
        
      end
      
      describe "random sorting" do

        it "returns the correct sparks" do
          seed = 0.3

          get :index, :format => 'json', :filter => "sparks", :seed => "#{seed}", :token => @auth_token
          output = JSON.parse(response.body)

          expect(output).to be_a_kind_of(Array)
          expect(output.length).to eq(@sparks.length)
          
          spark_ids = @sparks.map(&:id)
          ids = []
          
          output.each do |jawn|
            ids << jawn["id"]
          end
          
          ids.each do |id|
            spark_ids.delete id
          end
          
          expect(spark_ids).to be_empty
        end
        
        it "returns the same sparks with the same seed" do
          seed = 0.3
        
          get :index, :format => 'json', :filter => "sparks", :seed => "#{seed}", :token => @auth_token
          output = JSON.parse(response.body)
        
          get :index, :format => 'json', :filter => "sparks", :seed => "#{seed}", :token => @auth_token
          output2 = JSON.parse(response.body)
        
          expect(output.length).to eq(output2.length)
        
          output.each_with_index do |jawn, index|
            expect(jawn["id"]).to eq(output2[index]["id"])
          end
        end
        
        describe "offset" do
        
          it "uses the same order as without the offset" do
            seed = 0.3
        
            get :index, :format => 'json', :filter => "sparks", :seed => "#{seed}", :token => @auth_token
            output = JSON.parse(response.body)
        
            get :index, :format => 'json', :filter => "sparks", :seed => "#{seed}", :token => @auth_token, :offset => 5
            output2 = JSON.parse(response.body)
        
            expect(output2.length).to eq(output.length - 5)
        
            output2.each_with_index do |jawn, index|
              expect(jawn["id"]).to eq(output[index + 5]["id"])
            end
          end
        
        end

      end
      
    end
    
  end
  
  describe "GET 'count" do
    
    it "should have the correct sparks count" do
      get :count, :format => 'json', :token => @auth_token
      output = JSON.parse(response.body)

      expect(output).to be_a_kind_of(Hash)
      expect(output["sparks_count"]).to eq(@sparks.count)
    end
    
    it "should have the correct ideas count" do
      get :count, :format => 'json', :token => @auth_token
      output = JSON.parse(response.body)

      expect(output).to be_a_kind_of(Hash)
      expect(output["ideas_count"]).to eq(@ideas.count)
    end
    
    it "should have the correct jawns count" do
      get :count, :format => 'json', :token => @auth_token
      output = JSON.parse(response.body)

      expect(output).to be_a_kind_of(Hash)
      expect(output["jawns_count"]).to eq(@jawns.count)
    end
    
  end
  
end
