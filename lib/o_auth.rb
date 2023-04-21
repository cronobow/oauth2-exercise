class OAuth

  LINE_STATE = "Ey2YZv3icH6zh"

  def self.line_authorize_url(redirect_uri)
    auth_uri = "https://access.line.me/oauth2/v2.1/authorize"
    payload = { :response_type => "code",
                :client_id => Rails.application.credentials.line[:channel_id],
                :redirect_uri => redirect_uri,
                :state => LINE_STATE,
                :scope => "profile openid email"
              }

    uri = URI.parse(auth_uri)
    uri.query = URI.encode_www_form(payload)
    
    return uri.to_s
  end

  ## get access token form code
  def self.get_line_access_token(code, redirect_uri)
    payload = { :grant_type => "authorization_code",
                :code => code,
                :redirect_uri => redirect_uri,
                :client_id => Rails.application.credentials.line[:channel_id],
                :client_secret => Rails.application.credentials.line[:channel_secret]
              }

    response = RestClient.post("https://api.line.me/oauth2/v2.1/token" , payload)
 
    return JSON.parse(response.body)
  end

  ## get user profile from access token
  def self.get_line_user_profile(access_token)   
    hearder = { "Authorization" => "Bearer #{access_token}"}

    response = RestClient.get("https://api.line.me/v2/profile", hearder)

    return JSON.parse(response.body)
  end

  def self.line_login(code, redirect_uri)
    access_token = OAuth.get_line_access_token(code, redirect_uri)
    user_profile = OAuth.get_line_user_profile(access_token["access_token"])

    line_email = user_profile["email"] || "#{user_profile["userId"]}@line.oauth.com" # LINE 可能沒有回傳 Email

    user = if user_profile["email"].present?
             User.find_by(email: line_email)
           else
             User.find_by(line_uid: user_profile["userId"])
           end
           
    if user.nil?
      user = User.create(email: line_email,
                         password: Devise.friendly_token[0,20],
                         line_uid: user_profile["userId"])
    end

    return user
  end

end
