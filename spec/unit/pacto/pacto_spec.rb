describe Pacto do
  let(:tag) { 'contract_tag' }
  let(:another_tag) { 'another_tag' }
  let(:contract) { double('contract') }
  let(:another_contract) { double('another_contract') }

  around(:each) do |example|
    $stdout = StringIO.new
    example.run
    $stdout = STDOUT
  end

  def output
    $stdout.string.strip
  end

  after do
    described_class.unregister_all!
  end

  def mock_validation(errors)
    expect(JSON::Validator).to receive(:fully_validate).with(any_args()).and_return errors
  end

  describe '.validate_contract' do
    context 'valid' do
      it 'should display a success message and return true' do
        mock_validation []
        success = Pacto.validate_contract 'my_contract.json'
        output.should eq "All contracts successfully meta-validated"
        success.should be_true
      end
    end

    context 'invalid' do
      it 'should display one error messages and return false' do
        mock_validation ['Error 1']
        success = Pacto.validate_contract 'my_contract.json'
        output.should match /error/
        success.should be_false
      end

      it 'should display several error messages and return false' do
        mock_validation ['Error 1', 'Error 2']
        success = Pacto.validate_contract 'my_contract.json'
        success.should be_false
      end
    end
  end

  describe '.register' do
    context 'one tag' do
      it 'should register a contract under a given tag' do
        described_class.register_contract(contract, tag)
        expect(described_class.registered[tag]).to include(contract)
      end

      it 'should not duplicate a contract when it has already been registered with the same tag' do
        described_class.register_contract(contract, tag)
        described_class.register_contract(contract, tag)
        expect(described_class.registered[tag]).to include(contract)
        described_class.registered[tag].should have(1).items
      end
    end

    context 'multiple tags' do
      it 'should register a contract using different tags' do
        described_class.register_contract(contract, tag, another_tag)
        expect(described_class.registered[tag]).to include(contract)
        expect(described_class.registered[another_tag]).to include(contract)
      end

      it 'should register a tag with different contracts ' do
        described_class.register_contract(contract, tag)
        described_class.register_contract(another_contract, tag)
        expect(described_class.registered[tag]).to include(contract, another_contract)
      end

    end

    context 'with a block' do
      it 'should have a compact syntax for registering multiple contracts' do
        described_class.register do |r|
          r.register_contract 'new_api/create_item_v2', :item, :new
          r.register_contract 'authentication', :default
          r.register_contract 'list_items_legacy', :legacy
          r.register_contract 'get_item_legacy', :legacy
        end
        expect(described_class.registered[:new]).to include('new_api/create_item_v2')
        expect(described_class.registered[:default]).to include('authentication')
        expect(described_class.registered[:legacy]).to include('list_items_legacy', 'get_item_legacy')
      end
    end
  end

  describe '.build_from_file' do
    let(:path)                  { 'contract/path' }
    let(:host)                  { 'http://localhost' }
    let(:file_pre_processor)    { double('file_pre_processor') }
    let(:instantiated_contract) { double(:instantiated_contract) }

    it 'delegates to ContractFactory' do
      Pacto::ContractFactory.should_receive(:build_from_file).with(path, host, file_pre_processor)
      described_class.build_from_file(path, host, file_pre_processor)
    end

    it 'returns whatever the factory returns' do
      Pacto::ContractFactory.stub(:build_from_file => instantiated_contract)
      described_class.build_from_file(path, host, file_pre_processor).should == instantiated_contract
    end
  end

  describe '.use' do
    before do
      described_class.register_contract(contract, tag)
    end

    context 'by default' do
      let(:instantiated_contract) { double('instantiated contract', :response_body => response_body)}
      let(:response_body) { double('response_body') }

      before do
        contract.stub(:instantiate => instantiated_contract)
        instantiated_contract.stub(:stub!)
      end

      it 'should instantiate a contract with default values' do
        contract.should_receive(:instantiate).and_return(instantiated_contract)
        described_class.use(tag)
      end

      it 'should return a set including the instantiated contract' do
        expect(described_class.use(tag)).to include(instantiated_contract)
      end

      it 'should stub further requests with the instantiated contract' do
        instantiated_contract.should_receive(:stub!)
        described_class.use(tag)
      end

      it 'should use contracts within the default tag' do
        described_class.register_contract(contract, :default)
        contract.should_receive(:instantiate).and_return(instantiated_contract)
        described_class.use('junk')
      end
    end

    context 'when contract has not been registered' do
      it 'should raise an argument error' do
        expect { described_class.use('unregistered') }.to raise_error ArgumentError
      end
    end
  end

  describe '.unregister_all!' do
    it 'should unregister all previously registered contracts' do
      described_class.register_contract(contract, tag)
      described_class.unregister_all!
      described_class.registered.should be_empty
    end
  end
  describe "configure" do
    
    let (:contracts_path) {"path_to_contracts"}
    it 'should allow preprocessor manual configuration' do
      Pacto.configuration.preprocessor.should_not be_nil
      Pacto.configure do |c|
        c.preprocessor = nil
      end
      Pacto.configuration.preprocessor.should be_nil
    end
    
    it 'should allow contracts_path manual configuration' do
      Pacto.configuration.contracts_path.should be_nil
      Pacto.configure do |c|
        c.contracts_path = contracts_path
      end
      Pacto.configuration.contracts_path.should eql(contracts_path)
    end
  end
end
