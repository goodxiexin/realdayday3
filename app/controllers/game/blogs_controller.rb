class Game::BlogsController < ApplicationController

  layout 'app'

  before_filter :login_required, :setup

  def index
    @blogs = @game.blogs.paginate :page => params[:page], :per_page => 10
  end

protected

  def setup
    @game = Game.find(params[:game_id])
    @user = current_user
  rescue
    not_found
  end


end
