class EntriesController < ApplicationController
  def show
    entry = retrieve_service.execute(name: params[:id])
    return not_found unless entry
    render json: entry, status: :ok
  end

  def create
    result = create_service.execute(entry_params)
    render json: { status: :ok }
  end

  def index
    @entries = retrieve_service.execute(query_options)
    return not_found if @entries.blank?
    render json: @entries
  end

  def destroy
    result = delete_service.execute(name: params[:id])
    return not_found unless result
    render json: { status: 'ok' }, status: 200
  end

  private

  def create_service
    Boards::UpdateService.new
  end

  def retrieve_service
    Boards::GetService.new
  end

  def delete_service
    Boards::DeleteService.new
  end

  def entry_params
    (params[:entry] || {}).slice(:name, :score)
  end
end
