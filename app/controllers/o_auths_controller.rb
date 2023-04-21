class OAuthsController < ApplicationController

  def line_authorize
    redirect_to OAuth.line_authorize_url(line_callback_url), allow_other_host: true
  end

  def line_callback
    if params[:state] == OAuth::LINE_STATE
      code = params[:code]

      @user = OAuth.line_login(code, line_callback_url)

      sign_in(@user)
    end

    redirect_to root_path
  end
  
end
