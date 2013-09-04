module Pacto
  module Stubs
    describe StubProvider do
      subject(:stub_provider) { StubProvider }

      it "returns an instance of BuiltIn stub" do
        described_class.instance.should be_kind_of ::Pacto::Stubs::BuiltIn
      end
    end
  end
end
