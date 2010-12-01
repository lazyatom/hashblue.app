require 'cgi'
require 'uri'

class OpenURLCommand < NSScriptCommand

	# This is called when our application is opened with a URL; we need to
	# get the OAuth authorization code from the URL, and then continue on to get
	# an access token.
	def performDefaultImplementation
		url = URI.parse(self.directParameter)
		puts "opened with #{url}"
		params = CGI.parse(url.query)
		code = params["code"][0]
		
		# We can call this because MyController is set as the Application's delegate
		# in Interface Builder.
		NSApplication.sharedApplication.delegate.oauth_manager.getAccessToken(code)
	end
end