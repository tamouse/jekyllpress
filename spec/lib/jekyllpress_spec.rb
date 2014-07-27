require 'spec_helper'

describe "#version" do
  it "returns the version string" do
    result = Jekyllpress::App.start(["-V"])
    expect(result).to include(Jekyllpress::VERSION)
  end  
end