module Pacto
  describe ERBProcessor do
    describe "#process" do
      it "should return the result of ERB" do
        subject.process("2 + 2 = <%= 2 + 2 %>").should == "2 + 2 = 4"
      end
      
      it "should not mess with pure JSONs" do
        subject.process('{"property": ["one", "two, null"]}')
      end
    end
  end
end