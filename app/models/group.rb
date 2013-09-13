class Group < ActiveRecord::Base

  ## Macros ##

  strip_attributes

  ## Associations ##

  has_many :kits,        :through    => :permissions
  has_many :memberships, :inverse_of => :group
  has_many :permissions, :inverse_of => :group,       :dependent => :destroy
  has_many :users,       :through    => :memberships, :order => "users.username ASC"


  ## Mass-assignable Attributes ##

  attr_accessible(:description,
                  :expires_at,
                  :memberships_attributes,
                  :permissions_attributes,
                  :name)

  accepts_nested_attributes_for(:memberships,
                                :reject_if => proc { |attributes| attributes['user_id'].blank? },
                                :allow_destroy=> true)

  accepts_nested_attributes_for(:permissions,
                                :reject_if => proc { |attributes| attributes['kit_id'].blank? },
                                :allow_destroy=> true)

  # TODO: there is an outstanding Rails bug, which makes these
  # validations meaningless:
  # https://github.com/rails/rails/issues/4568
  #
  # I added a unique index to the each table to enforce this at the DB
  # level, but it throws ugly errors
  # validates_associated :memberships
  # validates_associated :permissions

  def self.active_with_kit_and_user_counts
    joins_sql = <<-END_SQL
      inner join (
          select group_id, expires_at, count(user_id) as num_users
          from memberships
          group by group_id, expires_at
        ) as t1 ON groups.id = t1.group_id
      inner join (
          select group_id, count(kit_id) as num_kits
          from permissions
          group by group_id
        ) as t2 on groups.id = t2.group_id
    END_SQL

    select("groups.*, t1.num_users, t2.num_kits")
      .joins(joins_sql)
      .where(["t1.expires_at IS NULL OR t1.expires_at >= ?", Date.today])
  end

  def self.all_with_kit_and_user_counts
    joins_sql = <<-END_SQL
      left join (
          select group_id, expires_at, count(user_id) as num_users
          from memberships
          group by group_id, expires_at
        ) as t1 ON groups.id = t1.group_id
      left join (
          select group_id, count(kit_id) as num_kits
          from permissions
          group by group_id
        ) as t2 on groups.id = t2.group_id
    END_SQL

    select("groups.*, t1.num_users, t2.num_kits")
      .joins(joins_sql)
  end

  def self.empty_with_kit_and_user_counts
    joins_sql = <<-END_SQL
      left join (
          select group_id, expires_at, count(user_id) as num_users
          from memberships
          group by group_id, expires_at
          having count(user_id) IS NULL OR count(user_id) < 1
        ) as t1 ON groups.id = t1.group_id
      left join (
          select group_id, count(kit_id) as num_kits
          from permissions
          group by group_id
          having count(kit_id) IS NULL OR count(kit_id) < 1
        ) as t2 on groups.id = t2.group_id
    END_SQL

    select("groups.*, t1.num_users, t2.num_kits")
      .joins(joins_sql)
  end

  def self.expired_with_kit_and_user_counts
    joins_sql = <<-END_SQL
      left join (
          select group_id, expires_at, count(user_id) as num_users
          from memberships
          group by group_id, expires_at
        ) as t1 ON groups.id = t1.group_id
      left join (
          select group_id, count(kit_id) as num_kits
          from permissions
          group by group_id
        ) as t2 on groups.id = t2.group_id
    END_SQL

    select("groups.*, t1.num_users, t2.num_kits")
      .where(["t1.expires_at < ?", Date.today])
      .joins(joins_sql)
  end

  def to_param
    "#{ id } #{ name }".parameterize
  end

end
