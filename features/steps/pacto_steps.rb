Given(/^Pacto is configured with:$/) do |string|
  steps %Q{
    Given a file named "pacto_config.rb" with:
    """ruby
    #{string}
    """
  }
end

Given(/^I have a Rakefile$/) do
  steps %Q{
    Given a file named "Rakefile" with:
    """ruby
    require 'pacto/rake_task'
    """
  }
end

When(/^I request "(.*?)"$/) do |url|
  steps %Q{
    Given a file named "request.rb" with:
    """ruby
    require 'pacto'
    require_relative 'pacto_config'
    require 'faraday'

    resp = Faraday.get('#{url}') do |req|
      req.headers = { 'Accept' => 'application/json' }
    end
    puts resp.body
    """
    When I run `bundle exec ruby request.rb`
  }
end

Given(/^an existing set of services$/) do
  WebMock.stub_request(:get, 'www.example.com/service1').to_return(:body => {'thoughtworks' => 'pacto' }.to_json)
  WebMock.stub_request(:post, 'www.example.com/service1').with(:body => 'thoughtworks').to_return(:body => 'pacto')
  WebMock.stub_request(:get, 'www.example.com/service2').to_return(:body => {'service2' => %w{'thoughtworks', 'pacto'} }.to_json)
  WebMock.stub_request(:post, 'www.example.com/service2').with(:body => 'thoughtworks').to_return(:body => 'pacto')
end

When(/^I execute:$/) do |script|
  FileUtils.mkdir_p 'tmp/aruba'
  Dir.chdir 'tmp/aruba' do
    begin
      script = <<-eof
      require 'stringio'
      begin $stdout = StringIO.new
        #{script}
        $stdout.string
      ensure
        $stdout = STDOUT
      end
eof
      eval(script) # rubocop:disable Eval
                   # It's just for testing...

    rescue SyntaxError => e
      puts e
      puts e.backtrace
    end
  end
end

When /^I make replacements in "([^"]*)":$/ do |file_name, replacements|
  Dir.chdir 'tmp/aruba' do
    content = File.read file_name
    replacements.rows.each do | pattern, replacement |
      content.gsub! Regexp.new(pattern), replacement
    end

    File.open(file_name, 'w') { |file| file.write content }
  end
end
