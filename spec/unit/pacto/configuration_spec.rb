module Pacto
  describe Configuration do
    subject(:configuration) { Configuration.new }
    let(:contracts_path) { 'path_to_contracts' }

    it 'sets the preprocessor by default to ERBProcessor' do
      expect(configuration.preprocessor).to be_kind_of ERBProcessor
    end

    it 'sets the postprocessor by default to HashMergeProcessor' do
      expect(configuration.postprocessor).to be_kind_of HashMergeProcessor
    end

    it 'sets the stub provider by default to BuiltIn' do
      expect(configuration.provider).to be_kind_of Stubs::BuiltIn
    end

    it 'sets strict matchers by default to true' do
      expect(configuration.strict_matchers).to be_true
    end

    it 'sets contracts path by default to nil' do
      expect(configuration.contracts_path).to be_nil
    end

    it 'sets logger by default to Logger' do
      expect(configuration.logger).to be_kind_of Logger
    end

    context 'about logging' do
      around do |example|
        ENV['PACTO_DEBUG'] = 'true'
        example.run
        ENV.delete 'PACTO_DEBUG'
      end

      it 'sets the log level to debug if the environment variable PACTO_DEBUG is enabled' do
        expect(configuration.logger.level).to eq :debug
      end
    end
  end
end
