class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise(:database_authenticatable, :lockable, :registerable,
         :recoverable, :rememberable, :timeoutable, :trackable,
         :validatable)

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation
end
