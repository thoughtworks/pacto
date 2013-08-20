module Pacto
	describe Response do
    let(:body_definition) do
      {:type => "object", :required => true, :properties => double("body definition properties")}
    end
    let(:definition) do
      {
        'status' => 200,
        'headers' => {'Content-Type' => 'application/json'},
        'body' => body_definition
      }
    end

		describe '#instantiate' do
			let(:generated_body) { double('generated body') }

			it 'should instantiate a response with a body that matches the given definition' do
				JSON::Generator.should_receive(:generate).
					with(definition['body']).
					and_return(generated_body)

				response = described_class.new(definition).instantiate
				response.status.should == definition['status']
				response.headers.should == definition['headers']
				response.body.should == generated_body
			end
		end

    describe '#validate' do
      let(:status) { 200 }
      let(:headers) { {'Content-Type' => 'application/json', 'Age' => '60'} }
      let(:response_body) { {'message' => 'response'} }
      let(:fake_response) do
        double({
          :status => status,
          :headers => headers,
          :body => response_body
        })
      end

      context 'when status, headers and body match' do
        it 'should not return any errors' do
          JSON::Validator.should_receive(:fully_validate).
            with(definition['body'], fake_response.body).
            and_return([])

          response = described_class.new(definition)
          response.validate(fake_response).should == []
        end
      end
      
      context 'when body is a pure string and matches the description' do
        let(:string_required) { true }
        let(:body_definition) do
          { 'type' => 'string', 'required' => string_required }
        end
        let(:response_body) { "a simple string" }
        
        it 'should not validate using JSON Schema' do
          response = described_class.new(definition)
          
          JSON::Validator.should_not_receive(:fully_validate)
          response.validate(fake_response)
        end
        
        context 'if required' do
          it 'should not return an error when body is a string' do
            response = described_class.new(definition)
          
            response.validate(fake_response).should == []
          end
          
          it 'should return an error when body is nil' do
            response = described_class.new(definition)
            
            fake_response.stub(:body).and_return(nil)
            response.validate(fake_response).size.should == 1
          end
        end
        
        context 'if not required' do
          let(:string_required) { false }
          
          it 'should not return an error when body is a string' do
            response = described_class.new(definition)
          
            response.validate(fake_response).should == []
          end
          
          it 'should not return an error when body is nil' do
            response = described_class.new(definition)
            
            fake_response.stub(:body).and_return(nil)
            response.validate(fake_response).should == []
          end
        end
        
        context 'if contains pattern' do
          let(:body_definition) do
            { 'type' => 'string', 'required' => string_required, 'pattern' => 'a.c' }
          end
          
          context 'body matches pattern' do
            let(:response_body) { 'cabcd' }
            
            it "should not return an error" do
              response = described_class.new(definition)
              
              response.validate(fake_response).should == []
            end
          end
          
          context 'body does not match pattern' do
            let(:response_body) { 'cabscd' }
            
            it "should return an error" do
              response = described_class.new(definition)
              
              response.validate(fake_response).size.should == 1
            end
          end
          
        end
      end
      
      context 'when status does not match' do
        let(:status) { 500 }

        it 'should return a status error' do
          JSON::Validator.should_not_receive(:fully_validate)
          
          response = described_class.new(definition)
          response.validate(fake_response).should == ["Invalid status: expected #{definition['status']} but got #{status}"]
        end
      end

      context 'when headers do not match' do
        let(:headers) { {'Content-Type' => 'text/html'} }

        it 'should return a header error' do
          JSON::Validator.should_not_receive(:fully_validate)

          response = described_class.new(definition)
          response.validate(fake_response).should == ["Invalid headers: expected #{definition['headers'].inspect} to be a subset of #{headers.inspect}"]
        end
      end

      context 'when headers are a subset of expected headers' do
        let(:headers) { {'Content-Type' => 'application/json'} }

        it 'should not return any errors' do
          JSON::Validator.stub(:fully_validate).and_return([])

          response = described_class.new(definition)
          response.validate(fake_response).should == []
        end
      end

      context 'when headers values match but keys have different case' do
        let(:headers) { {'content-type' => 'application/json'} }

        it 'should not return any errors' do
          JSON::Validator.stub(:fully_validate).and_return([])

          response = described_class.new(definition)
          response.validate(fake_response).should == []
        end
      end

      context 'when body does not match' do
        let(:errors) { [double('error1'), double('error2')] }

        it 'should return a list of errors' do
          JSON::Validator.stub(:fully_validate).and_return(errors)

          response = described_class.new(definition)
          response.validate(fake_response).should == errors
        end
      end

      context 'when body not specified' do
        let(:definition) do
          {
            'status' => status,
            'headers' => headers
          }
        end

        it 'should not validate body' do
          JSON::Validator.should_not_receive(:fully_validate)
          response = described_class.new(definition)
        end

        it 'should give no errors' do
          response = described_class.new(definition)
          response.validate(fake_response).should == []
        end
      end
    end
	end
end
