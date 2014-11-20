require 'octokit'

def github
  @client ||= Octokit::Client.new :access_token => ENV['GITHUB_TOKEN']
end

def release_tag
  "v#{Pacto::VERSION}"
end

def release
  @release ||= github.list_releases('thoughtworks/pacto').find{|r| r.name == release_tag }
end

def changelog
  changelog = File.read('changelog.md').split("\n\n\n", 2).first
  confirm 'Does the CHANGELOG look correct? ', changelog
end

def confirm(question, data)
  puts 'Please confirm...'
  puts data
  print question
  abort 'Aborted' unless $stdin.gets.strip == 'y'
  puts 'Confirmed'
  data
end

desc 'Tags and pushes the gem'
task :release_gem do
  sh 'git', 'tag', '-m', changelog, "v#{Pacto::VERSION}"
  sh 'git push origin master'
  sh "git push origin v#{Pacto::VERSION}"
  sh 'ls pkg/*.gem | xargs -n 1 gem push'
end

desc 'Releases to RubyGems and GitHub'
task :release => [:build, :release_gem, :samples, :package, :create_release, :upload_docs]

desc 'Preview the changelog'
task :changelog do
  changelog
end

desc 'Create a release on GitHub'
task :create_release do
  github.create_release 'thoughtworks/pacto', release_tag, {:name => release_tag, :body => changelog}
end

desc 'Upload docs to the GitHub release'
task :upload_docs do
  Dir['pkg/pacto_docs*'].each do |file|
    next if File.directory? file
    puts "Uploading #{file}"
    github.upload_asset release.url, file
  end
end
