class MetricsController < ApplicationController
	def index
		query = Global.api + "Kpi/Municipality/Names"
		response = RestClient.get(query)
		@data = JSON.parse(response.body)

		query = Global.api + "Kpi/Municipality/VehicleStops"

		@places = Array.new

		@data.each do |d|
			response = RestClient.post(query, d)
			@places.push JSON.parse(response.body)
		end

	rescue
		@data = JSON.parse("[]")
	end
end
