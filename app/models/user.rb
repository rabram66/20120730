class User < ActiveRecord::Base

  ROLES = %w(guest user promoter admin)
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :roles
  has_many :locations
  has_many :events
  
  after_initialize :default_role

  scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0 "} }
  
  # Set the roles given an array of role names (as strings or symbols)
  def roles=(roles)
    self.roles_mask = (roles.map(&:to_s) & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end
  
  def role?(role)
    self.roles.include? role.to_s
  end

  def role_symbols
    roles.map(&:to_sym)
  end

  private
  
  def default_role
    self.roles=[:guest] if roles.empty?
  end
  
end
