class PagesController < ApplicationController
  allow_unauthenticated_access

  def about; end

  def privacy; end

  def terms; end
end
