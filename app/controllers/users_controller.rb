class UsersController < ApplicationController
  authorize_resource

  # GET /users
  # GET /users.json
  def index
    @users = UserDecorator.decorate(User.includes(:roles).page(params[:page]).per(params[:page_limit]))

    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = UserDecorator.includes(:roles).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
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
    @user = User.find(params[:id])
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

  # PUT /users/1
  # PUT /users/1.json
  def update
    p     = params[:user]
    @user = User.find(params[:id])

    @user.disabled        = p["disabled"]        if p["disabled"].present?
    @user.email           = p["email"]           if p["email"].present?
    @user.suspended_until = p["suspended_until"] if p["suspended_until"].present?
    @user.username        = p["username"]        if p["username"].present?

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

end
