require 'digest/sha1'
class User < ActiveRecord::Base
  before_create :make_activation_code
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  #attr_protected :activated_at
  has_many :role_users
  has_many :roles, :through => :role_users
  has_many :solutions,
           :conditions => ['isbest = ?', true],
           :include => [:problem, :language]
  has_many :duplicate_solutions, :class_name=> 'Solution',
           :include => [:problem, :language]
  has_many :contests,
           :finder_sql =>
    'SELECT distinct(c.id ), c.name, c.start, c.end, '+
    'c.type_id, c.prize_id, c.sponsor_id, t.name as type_name, '+
    'z.name as prize_name, o.name as sponsor_name '+
    'FROM solutions s '+
    'join problems p on s.problem_id = p.id '+
    'join contests c on p.contest_id = c.id '+
    'join prizes z on c.prize_id = z.id '+
    'join sponsors o on c.sponsor_id = o.id '+
    'join contest_types t on c.type_id = t.id '+
    'where s.user_id = #{id} and s.created_at < c.end '+
    'order by c.start desc'
  has_many :problems
  has_one :photo
  has_many :fulfillments
  has_many :courses, :foreign_key=>'teacher_id'
  has_many :memberships
  has_many :groups, :through => :memberships
  has_many :lessons, :foreign_key => 'author_id'

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "-Invalid email"
  before_save :encrypt_password

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #def self.authenticate(login, password)
  #  u = find_by_login(login) # need to get the salt
  #  u && u.authenticated?(password) ? u : nil
  #end
  def self.authenticate(login, password)
    # hide records with a nil activated_at
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # Activates the user in the database.
  def activate
    @activated = true
    update_attributes(:activated_at => Time.now, :activation_code => nil)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password
    # First update the password_reset_code before setting the
    # reset_password flag to avoid duplicate email notifications.
    update_attributes(:password_reset_code => nil)
    @reset_password = true
  end

  def recently_reset_password?
    @reset_password
  end

  def recently_forgot_password?
    @forgotten_password
  end

  protected
  # If you're going to use activation, uncomment this too
  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end
end
