require 'rubygems'
require 'sinatra'
require 'json'
require 'active_support'
require 'tinder'


post '/github_commits' do
  push = JSON.parse(params[:payload])

  # we don't know who pushed, so use authors instead
  authors = push['commits'].map { |c| c['author']['name'] }.uniq.to_sentence
  branch  = push['ref'].gsub(%r{^refs/heads/}, '')
  repo    = push['repository']['url'].match(%r{github\.com/(\w+/\w+)})[1]
  commits = push['commits'].reverse

  with_campfire do |room|
    room.speak "#{authors} pushed to #{branch} at #{repo}:"
    commits.each do |commit|
      room.speak commit['url']
      room.paste "[#{commit['id'][0...10]}] #{commit['message']}"
    end
  end

  "Done and done!"
end



def with_campfire
  config_file = File.join(File.dirname(__FILE__), 'config', 'campfire.yml')
  config = YAML.load_file(config_file).symbolize_keys!

  campfire = Tinder::Campfire.new(config[:subdomain], :ssl => config[:ssl])
  if campfire.login(config[:email], config[:password])
    if room = campfire.find_room_by_name(config[:room])
      yield room
    end
  end
end