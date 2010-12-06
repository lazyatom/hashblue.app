require 'net/https'
require 'uri'
require 'json/pure'

class OAuthManager
	IDENTIFIER = 'soaE0hCXWAE5jwpW'
	SECRET = 'LIYOzaHZnFoz98OF4CL31Ia7ZooKyM8J'
	HOST = 'hashblue.com'
	API_HOST = 'https://api.' + HOST
	OAUTH_SERVER = 'https://' + HOST

	# Load some data from the server, and yield it to the given block.
	# If this client is not authorized, we will perform the authorization and then
	# re-perform the action.
	def get(path, &block)
		if @token
			puts "Authorized, loading #{path}"
            uri = URI.parse(API_HOST)
			http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true if uri.scheme == 'https'
			headers = {
				'Accept' => 'application/json',
				'Authorization' => "OAuth #{@token['access_token']}"
			}
			response = http.get2(path, headers)
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
        uri = URI.parse(OAUTH_SERVER + "/oauth/access_token")
        request = Net::HTTP::Post.new(uri.path)
        request.set_form_data(params)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        response = http.start { |http| http.request(request) }
		if response.code == "200"
			token = JSON.parse(response.body)
			setToken(token)
			processStash
		else
          puts "Error: #{response.body}"
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