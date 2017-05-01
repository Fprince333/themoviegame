class ApplicationController < ActionController::API

  def query_options
    options = {}
    options[:limit] = [params.fetch(:limit, 10).to_i, 100].min
    options[:page] = params.fetch(:page, 1).to_i
    options
  end

  def not_found
    render json: { error: 'Not Found' }, status: :not_found
  end
end
