module JSON
  describe Generator do
    describe '.generate' do
      let(:attribute) { double('attribute') }
      let(:schema) { double('schema') }
      let(:dereferenced_schema) { double('dereferenced schema') }
      let(:generated_json) { double('generated json') }

      it 'should dereference a given schema and generate valid JSON for it' do
        JSON::Generator::Dereferencer.should_receive(:dereference).
          with(schema).
          and_return(dereferenced_schema)
        Generator::AttributeFactory.should_receive(:create).with(dereferenced_schema).and_return(attribute)
        attribute.should_receive(:generate).and_return(generated_json)

        described_class.generate(schema).should == generated_json
      end
    end
  end
end
