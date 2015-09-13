class TicketsController < ApplicationController
	def resolve
		@error = nil;

		if params[:ticket]
			query = Global.api + "Tickets/CitationNumber/" + params[:ticket].to_s
			response = RestClient.get(query)
			@ticket = JSON.parse(response.body)

			query = Global.api + "Court/Municipality/"
			response = RestClient.post(query, @ticket["courtLocation"].to_s)
			@court = JSON.parse(response.body)

			while !(@court["municipalCourt"].include? "X") &&
				    @court["municipalCourt"] != "NONE"
				query = Global.api + "Court/Municipality/"
				response = RestClient.post(query, @court["municipalCourt"].to_s)
				@court = JSON.parse(response.body)
			end

			query = Global.api + "Violation/CitationNumber/" + params[:ticket].to_s
			response = RestClient.get(query)
			@violations = JSON.parse(response.body)

			@violationFees = 0
			@violations.each do |v|
				@violationFees += v["fineAmount"].to_f
				@violationFees += v["courtCost"].to_f
			end

			render "resolve"
		else
			render "find"
		end

	rescue Exception => msg
		@error = msg
		render "find"
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
			@tickets = JSON.parse(response.body)
			@tickets.each do |t|
				response = RestClient.get(Global.api + "Violation/CitationNumber/" + t["citationNumber"].to_s)
				t["violations"] = JSON.parse(response.body)
			end

			session[:first] = params[:first]
			session[:last] = params[:last]

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
