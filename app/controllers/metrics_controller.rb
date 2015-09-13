class MetricsController < ApplicationController
	def index
		redirect_to Global.metrics
	end

	def show
		query = Global.api + "Kpi/Municipality/Full"
		response = RestClient.post(query, params[:place])
		@data = JSON.parse(response.body)

		render "show"
	rescue Exception => msg
		@error = msg
		redirect_to Global.metrics
	end
end
