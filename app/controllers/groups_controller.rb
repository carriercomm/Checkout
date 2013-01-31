class GroupsController < ApplicationController

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group
    authorize!(:index, Group)
    apply_scopes_and_pagination
    @groups = @groups.decorate

    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.includes(:kits).find(params[:id].to_i)
    authorize!(:show, @group)
    @group = @group.decorate

    # TODO: figure out how to sort this in the database
    @memberships = @group.memberships.sort_by {|m| m.username}

    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new
    authorize!(:create, @group)
    @group = @group.decorate

    respond_to do |format|
      format.html # new.html.erb
      # format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    # this doesn;t work because of the inner joins, it needs to be
    # broken up into separate intermediate tables
    # join_sql =<<-END_SQL
    # LEFT JOIN memberships ON groups.id = memberships.group_id
    # INNER JOIN users ON memberships.user_id = users.id
    # LEFT JOIN permissions ON groups.id = permissions.group_id
    # INNER JOIN kits ON permissions.kit_id = kits.id
    # END_SQL
    @group = Group.includes(:kits).find(params[:id])
    authorize!(:update, @group)
    # TODO: figure out how to sort this in the database
    @memberships = @group.memberships.sort_by { |m| m.user.username }
    # this has to come after creating @memberships, so @memberships is not decorated
    @group = @group.decorate
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(params[:group])
    authorize!(:create, @group)

    respond_to do |format|
      if @group.save
        @group = @group.decorate
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        # format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        # format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @group = Group.find(params[:id])
    authorize!(:update, @group)

    respond_to do |format|
      if @group.update_attributes(params[:group])
        @group = @group.decorate
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        # format.json { head :no_content }
      else
        @group = @group.decorate
        format.html { render action: "edit" }
        # format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      # format.json { head :no_content }
    end
  end

  private

  def apply_scopes_and_pagination
    scope_by_user

    @groups = @groups.includes(:kits, :users)
      .where(["memberships.expires_at IS NULL OR memberships.expires_at > ?", Date.today])
      .order("groups.name")
      .page(params[:page])
  end

  def scope_by_user
    @groups = @groups.users(params["user_id"]) if params["user_id"].present?
  end

end
