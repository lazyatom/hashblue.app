require 'OAuthManager'

class MyController < NSWindowController

  attr_writer :button
	attr_writer :details

	attr_accessor :oauth_manager
	attr_writer :table

  def clicked(sender)
		@oauth_manager.get("/messages") do |data|
			@messages = data["messages"]
			@table.reloadData
		end
  end

	def messages
		@messages || []
	end

	# delegate methods for table view
  def numberOfRowsInTableView(view)
    messages.length
  end

  def tableView(view, objectValueForTableColumn:column, row:index)
		case column.identifier
		when "from"
			contact = messages[index]["contact"]
			contact["name"] || contact["msisdn"]
		else
			messages[index][column.identifier]
		end
	end
end