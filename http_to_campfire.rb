require 'rubygems'
require 'sinatra'
require 'json'
require 'active_support'
require 'tinder'


campfire_auth = { :subdomain => '',
                  :email     => '',
                  :password  => '',
                  :room      => '' }
campfire = Tinder::Campfire.new(campfire_auth[:subdomain], :ssl => true)


post '/github_commits' do
  push = JSON.parse(params[:payload])

  # we don't know who pushed, so use authors instead
  authors = push['commits'].map { |c| c['author']['name'] }.uniq.to_sentence
  branch  = push['ref'].gsub(%r{^refs/heads/}, '')
  repo    = push['repository']['url'].match(%r{github\.com/(\w+/\w+)})[1]
  commits = push['commits'].reverse

  if campfire.login(campfire_auth[:email], campfire_auth[:password])
    if room = campfire.find_room_by_name(campfire_auth[:room])
      room.speak "#{authors} pushed to #{branch} at #{repo}:"
      commits.each do |commit|
        room.speak commit['url']
        room.paste "[#{commit['id'][0...10]}] #{commit['message']}"
      end
    end
  end
  "Done and done!"
end
