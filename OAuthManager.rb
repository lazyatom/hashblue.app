require 'net/http'
require 'uri'
require 'rubygems'
require 'json'

class OAuthManager
	IDENTIFIER = 'ru1tad9ccm47'
	SECRET = 'uueqvgfhecbok8glerjm9vg1ki94f07l'
	HOST = 'hashblue.local'
	API_HOST = 'api.' + HOST
	OAUTH_SERVER = 'http://' + HOST

	# Load some data from the server, and yield it to the given block.
	# If this client is not authorized, we will perform the authorization and then
	# re-perform the action.
	def get(path, &block)
		if @token
			puts "Authorized, loading #{path}"
			request = Net::HTTP.new(API_HOST)
			headers = {
				'Accept' => 'application/json',
				'Authorization' => "OAuth #{@token['access_token']}"
			}
			response = request.get2(path, headers)
			if response.code == "200"
				yield JSON.parse(response.body)
			else
				puts "Error: #{response.body}"
			end
		else
			puts "Not authorized..."
			stash(path, &block)
			getAuthorisation
		end
	end

	def getAccessToken(code)
		params = {:client_id => IDENTIFIER, :client_secret => SECRET, :type => 'web_server',
							:grant_type => 'authorization_code',
							:code => code, :redirect_uri => redirect_uri}
		response = Net::HTTP.post_form URI.parse(OAUTH_SERVER + "/oauth/access_token"), params
		if response.code == "200"
			token = JSON.parse(response.body)
			setToken(token)
			processStash
		end
	end

	private

	def getAuthorisation
		authorization_url = OAUTH_SERVER + "/oauth/authorize?client_id=#{IDENTIFIER}&redirect_uri=#{redirect_uri}"
		NSWorkspace.sharedWorkspace.openURL(NSURL.URLWithString(authorization_url))
	end

	def setToken(token)
		puts "setting token to #{token}"
		@token = token
	end

	def redirect_uri
		"hashblue://authorize"
	end

	def processStash
		get(@stashed_path, &@stashed_block)
	end

	def stash(path, &block)
		@stashed_path = path
		@stashed_block = block
	end
end