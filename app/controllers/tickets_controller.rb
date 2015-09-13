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
				@violationFees += v["fineAmount"].gsub(/[^\d\.]/, '').to_f
				@violationFees += v["courtCost"].gsub(/[^\d\.]/, '').to_f
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

		if params[:ticket_id] && params[:ticket_id].length > 0
			query = query + "/CitationNumber/" + params[:ticket_id]
		else
			dob = Date.civil(params[:dob][:year].to_i, params[:dob][:month].to_i, params[:dob][:day].to_i)
			dob = (dob.to_time.to_i * 1000).to_s
			query = query + "/FirstName/" + params[:first] + "/LastName/" + params[:last] + "/DoB/" + dob
		end

		response = RestClient.get(query)

		if (response.body != "[]")
			json = response.body
			if !json.start_with? '['
				json = '[' + json
			end
			if !json.end_with? ']'
				json = json + ']'
			end
			@tickets = JSON.parse(json)
			@tickets.each do |t|
				response = RestClient.get(Global.api + "Violation/CitationNumber/" + t["citationNumber"].to_s)
				t["violations"] = JSON.parse(response.body)
				t["violations"].each do |v|
					if v["warrantStatus"]
						t["warrantStatus"] = true
					end
				end
			end

			session[:first] = @tickets[0]["firstName"]
			session[:last] = @tickets[0]["lastName"]

			render "show"
		else
			@error = "Empty response."
		end
	rescue Exception => msg
		@error = msg
		render "find"
	end
end
