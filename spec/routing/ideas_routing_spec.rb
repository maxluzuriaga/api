require 'spec_helper'

describe "routes for Ideas", :type => :routing do
  
  it "routes get /api/v1/ideas.json to Ideas controller" do
    expect({ :get => "/api/v1/ideas.json" }).to route_to(
      :controller => "v1/ideas",
      :action => "index",
      :format => "json"
    )
  end
  
  it "routes post /api/v1/ideas.json to Ideas controller" do
    expect({ :post => "/api/v1/ideas.json" }).to route_to(
      :controller => "v1/ideas",
      :action => "create",
      :format => "json"
    )
  end
  
  it "routes get /api/v1/ideas/:id.json to Ideas controller" do
    expect({ :get => "/api/v1/ideas/1.json" }).to route_to(
      :controller => "v1/ideas",
      :action => "show",
      :id => "1",
      :format => "json"
    )
  end
  
  it "routes delete /api/v1/ideas/:id.json to Ideas controller" do
    expect({ :delete => "/api/v1/ideas/1.json" }).to route_to(
      :controller => "v1/ideas",
      :action => "destroy",
      :id => "1",
      :format => "json"
    )
  end
  
end