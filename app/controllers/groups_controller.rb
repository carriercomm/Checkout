class GroupsController < ApplicationController

  # use CanCan to authorize this resource
  authorize_resource

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group
    apply_scopes_and_pagination
    @groups = GroupDecorator.decorate(@groups)

    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.includes(:kits).find(params[:id].to_i)
    @group = GroupDecorator.decorate(@group)

    # TODO: figure out how to sort this in the database
    @memberships = @group.memberships.sort_by {|m| m.username}
    @memberships = MembershipDecorator.decorate(@memberships)

    respond_to do |format|
      format.html # show.html.erb
      # format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    @group = Group.new
    @group = GroupDecorator.decorate(@group)

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
    # TODO: figure out how to sort this in the database
    @memberships = @group.memberships.sort_by {|m| m.user.username}
    # this has to come after creating @memberships
    @group = GroupDecorator.decorate(@group)
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(params[:group])
    @group = GroupDecorator.decorate(@group)

    respond_to do |format|
      if @group.save
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
    @group = GroupDecorator.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        # format.json { head :no_content }
      else
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
      .order("groups.name").page(params[:page])
  end

  def scope_by_user
    @groups = @groups.users(params["user_id"]) if params["user_id"].present?
  end

end
