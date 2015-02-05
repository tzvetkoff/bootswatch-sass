class HomeController < ApplicationController
  THEMES = %w[
    cerulean cosmo cyborg darkly flatly journal lumen paper readable
    sandstone simplex slate spacelab superhero united yeti
  ]

  def index
    @stylesheet = params[:theme].in?(THEMES) ? params[:theme] : 'application'
  end
end
