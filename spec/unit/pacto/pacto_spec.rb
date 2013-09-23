describe Pacto do

  around(:each) do |example|
    $stdout = StringIO.new
    example.run
    $stdout = STDOUT
  end

  def output
    $stdout.string.strip
  end

  def mock_validation(errors)
    expect(JSON::Validator).to receive(:fully_validate).with(any_args).and_return errors
  end

  describe '.validate_contract' do
    context 'valid' do
      it 'should display a success message and return true' do
        mock_validation []
        success = Pacto.validate_contract 'my_contract.json'
        output.should eq 'All contracts successfully meta-validated'
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

end
