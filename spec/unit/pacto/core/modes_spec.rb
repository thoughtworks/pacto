describe Pacto do
  modes = %w(generate validate)
  modes.each do |mode|
    enable_method = "#{mode}!".to_sym # generate!
    query_method = "#{mode[0..-2]}ing?".to_sym # generating?
    disable_method = "stop_#{mode[0..-2]}ing!".to_sym # stop_generating!
    describe ".#{mode}!" do
      it "tells the provider to enable #{mode} mode" do
        expect(subject.send query_method).to be_falsey
        subject.send enable_method
        expect(subject.send query_method).to be true

        subject.send disable_method
        expect(subject.send query_method).to be_falsey
      end
    end
  end
end
