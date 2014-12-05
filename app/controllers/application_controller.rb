class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user
  before_filter :increase_traffic_counter

  TRAFFIC_DECREMENTER = 0.25

  TAG_FILTER_COOKIE = :tag_filters

  def authenticate_user
    user_id = request.env["HTTP_X_SANDSTORM_USER_ID"].to_s
    user = User.where(:username => user_id).first
    if user
      @user = user
      Rails.logger.info "  Logged in as user #{@user.id} (#{@user.username})"
    else
      Rails.logger.info " Creating new user #{user_id}"
      user = User.new(:username => user_id, :email => user_id + "@example.com", :password => "xyzzy", :password_confirmation => "xyzzy")
      user.save
      @user = user
    end

    permissions = request.env["HTTP_X_SANDSTORM_PERMISSIONS"].to_s
    permission_list = permissions.split(',')

    needs_resave = false

    if permission_list.include? 'admin'
      user.is_admin = true
      needs_resave = true
    end
    if permission_list.include? 'admin'
      user.is_moderator = true
      needs_resave = true
    end

    if needs_resave
      user.save
    end

    true
  end

  def increase_traffic_counter
    @traffic = 1.0

    if user_is_spider? || [ "json", "rss" ].include?(params[:format])
      return true
    end

    Keystore.transaction do
      now_i = Time.now.to_i
      date_kv = Keystore.find_or_create_key_for_update("traffic:date", now_i)
      traffic_kv = Keystore.find_or_create_key_for_update("traffic:hits", 0)

      # increment traffic counter on each request
      traffic = traffic_kv.value.to_i + 100
      # every second, decrement traffic by some amount
      traffic -= (100.0 * (now_i - date_kv.value) * TRAFFIC_DECREMENTER).to_i
      # clamp
      traffic = [ 100, traffic ].max

      @traffic = traffic * 0.01

      traffic_kv.value = traffic
      traffic_kv.save!

      date_kv.value = now_i
      date_kv.save!
    end

    Rails.logger.info "  Traffic level: #{@traffic}"

    true
  end

  def require_logged_in_user
    if @user
      true
    else
      if request.get?
        session[:redirect_to] = request.original_fullpath
      end

      redirect_to "/login"
    end
  end

  def require_logged_in_user_or_400
    if @user
      true
    else
      render :text => "not logged in", :status => 400
      return false
    end
  end

  @_tags_filtered = nil
  def tags_filtered_by_cookie
    @_tags_filtered ||= Tag.where(
      :tag => cookies[TAG_FILTER_COOKIE].to_s.split(",")
    )
  end

  def user_is_spider?
    ua = request.env["HTTP_USER_AGENT"].to_s
    (ua == "" || ua.match(/(Google|bing)bot/))
  end

  def find_user_from_rss_token
    if !@user && request[:format] == "rss" && params[:token].to_s.present?
      @user = User.where(:rss_token => params[:token].to_s).first
    end
  end
end
