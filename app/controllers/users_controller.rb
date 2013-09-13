class UsersController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource

  # make these methods available in the views
  helper_method :sort_column, :sort_direction

  decorates_assigned :trainings
  decorates_assigned :user
  decorates_assigned :users

  # GET /users
  # GET /users.json
  def index
    @users  = User.includes(:roles, :groups)
      .order(sort_column + " " + sort_direction)

    if params[:filter]
      case params[:filter]
      when "active"        then @users = @users.where(:disabled => false)
      when "disabled"      then @users = @users.where(:disabled => true)
      when "suspended"     then @users = @users.where(["users.suspended_until > ?", Date.today])
      when "administrator" then @users = @users.where("roles.name = 'admin'")
      when "attendant"     then @users = @users.where("roles.name = 'attendant'")
      end
    end

    # get a total (used by the select2 widget) before we apply pagination
    @total = @users.count
    @users = @users.page(params[:page])
      .per(params[:page_limit])

    respond_to do |format|
      format.html # index.html.erb
      #format.json { render json: { items: @users.map(&:select2_json), total: @total} }
    end
  end

  def search
    q     = params["q"]
    total = User.search(q).count
    users = User.search(q)
      .page(params[:page])
      .per(params[:page_limit])

    respond_to do |format|
      format.json { render json: { results: users, total: total } }
    end
  end

  # GET /users/select2.json
  def select2
    users = User

    # constrain the query to find users not already in a specified group
    if params[:group_id].present?
      users = users.not_in_group(params["group_id"])
    end

    users = users.username_search(params["q"])

    # get a count of all the users meeting the query params
    total = users.count

    # grab the first 10
    users = users.limit(10).decorate

    respond_to do |format|
      #format.html # index.html.erb
      format.json { render json: { items: users.map(&:select2_json), total: total} }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.includes(:roles, :component_models, :groups, :memberships).find(params[:id])
    @trainings = @user.trainings

    respond_to do |format|
      format.html { render layout: 'sidebar' } # show.html.erb
      # format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      # format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.includes(:groups, :roles).find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    p     = params[:user]
    @user = User.new

    # generate a random password
    @user.password        = Devise.friendly_token.first(6)
    @user.disabled        = p[:disabled]        if p[:disabled].present?
    @user.email           = p[:email]           if p[:email].present?
    @user.suspended_until = p[:suspended_until] if p[:suspended_until].present?
    @user.username        = p[:username]        if p[:username].present?
    @user.first_name      = p[:first_name]      if p[:first_name].present?
    @user.last_name       = p[:last_name]       if p[:last_name].present?
    @user.role_ids        = p[:role_ids]        if p[:role_ids].present?

    # TODO: this is possibly dangerous, is there a more manual way to handle it?
    @user.memberships_attributes = p[:memberships_attributes] if p[:memberships_attributes].present?
    @user.trainings_attributes   = p[:trainings_attributes]   if p[:trainings_attributes].present?

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        # format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        # format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # TODO: DRY this up with create
  # PUT /users/1
  # PUT /users/1.json
  def update
    p     = params[:user]
    @user = User.find(params[:id])

    raise "Cannot change the system user" if @user == User.system_user

    @user.disabled        = p[:disabled]        if p[:disabled].present?
    @user.email           = p[:email]           if p[:email].present?
    @user.suspended_until = p[:suspended_until] if p[:suspended_until].present?
    @user.username        = p[:username]        if p[:username].present?
    @user.first_name      = p[:first_name]      if p[:first_name].present?
    @user.last_name       = p[:last_name]       if p[:last_name].present?
    @user.role_ids        = p[:role_ids]        if p[:role_ids].present?

    # TODO: this is possibly dangerous, is there a more manual way to handle it?
    @user.memberships_attributes = p[:memberships_attributes] if p[:memberships_attributes].present?
    @user.trainings_attributes   = p[:trainings_attributes]   if p[:trainings_attributes].present?

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        # format.json { head :no_content }
      else
        format.html { render action: "edit" }
        # format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "username"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end
