#!/usr/bin/env ruby
require 'slop'
require 'json'

opts = Slop.parse do |o|
  o.string '-n', '--name', 'repository name'
  o.string '-d', '--description', 'repository description'
  o.bool '--private', 'make repository private'
  o.bool '--help', 'display usage'
end

if !opts[:name] or opts[:help]
  puts opts
  exit
end

if !File.exists?(Dir.home + '/.gitclirc')
  puts "~/.gitclirc not found"
  puts "Run `echo 'user:pass' > ~/.gitclirc`"
  exit
end

user,pass = File.open(Dir.home + '/.gitclirc','r').read.strip.split ':'

packet = {
  :name => opts[:name],
}

if opts[:description]
  packet[:description] = opts[:description]
end

if opts[:private]
  packet[:private] = true
end

system 'git init'

system """
  git remote add origin https://github.com/#{user}/#{packet[:name]}.git
"""

system """
  curl -u '#{user}:#{pass}' https://api.github.com/user/repos -d '#{packet.to_json}'
"""

