require 'spec_helper'

describe "routes for Sparks", :type => :routing do
  
  it "routes get /api/v1/sparks.json to Sparks controller" do
    expect({ :get => "/api/v1/sparks.json" }).to route_to(
      :controller => "v1/sparks",
      :action => "index",
      :format => "json"
    )
  end
  
  it "routes post /api/v1/sparks.json to Sparks controller" do
    expect({ :post => "/api/v1/sparks.json" }).to route_to(
      :controller => "v1/sparks",
      :action => "create",
      :format => "json"
    )
  end
  
  it "routes get /api/v1/sparks/:id.json to Sparks controller" do
    expect({ :get => "/api/v1/sparks/1.json" }).to route_to(
      :controller => "v1/sparks",
      :action => "show",
      :id => "1",
      :format => "json"
    )
  end
  
  it "routes delete /api/v1/sparks/:id.json to Sparks controller" do
    expect({ :delete => "/api/v1/sparks/1.json" }).to route_to(
      :controller => "v1/sparks",
      :action => "destroy",
      :id => "1",
      :format => "json"
    )
  end
  
end