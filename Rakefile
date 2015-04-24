require_relative 'lib/version'

desc 'build a release'
task :build do
  `gem build sequent-sinatra.gemspec`
end

desc 'tag and push release to git and rubygems'
task :release => :build do
  `git tag v#{SequentSinatra::VERSION}`
  `git push --tags`
  `gem push sequent-sinatra-#{SequentSinatra::VERSION}.gem`
end
