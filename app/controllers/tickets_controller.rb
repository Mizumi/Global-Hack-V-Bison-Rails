class TicketsController < ApplicationController
	def dispute
		if params[:ticket_id] && session[:ticket] &&
		   session[:ticket]["citationNumber"].to_s == params[:ticket_id].to_s
			@ticket = session[:ticket]
			render "dispute"
		else
			render "find"
		end
	end

	def pay
		if params[:ticket_id] && session[:ticket] &&
		   session[:ticket]["citationNumber"].to_s == params[:ticket_id].to_s
			@ticket = session[:ticket]
			render "pay"
		else
			render "find"
		end
	end

	def show
		@error = nil;

		query = Global.api + "Tickets"

		if params[:ticket_id]
			query = query + "/id/" + params[:ticket_id]
		else
			dob = Date.civil(params[:dob][:year].to_i, params[:dob][:month].to_i, params[:dob][:day].to_i)
			dob = (dob.to_time.to_i * 1000).to_s
			query = query + "/FirstName/" + params[:first] + "/LastName/" + params[:last] + "/DoB/" + dob
		end

		response = RestClient.get(query)

		if (response.body != "[]")
			@ticket = JSON.parse(response.body)[0]
			session[:ticket] = @ticket
			render "show"
		else
			@error = "Empty response."
			render "find"
		end
	rescue Exception => msg
		@error = msg
		render "find"
	end
end
