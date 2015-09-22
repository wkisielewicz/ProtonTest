require 'provision'
require 'openssl'
require 'edn'

class Account
  attr_accessor :user_email
  attr_accessor :admin_email
  attr_accessor :license
  attr_accessor :friendly_name
  attr_accessor :id
  attr_accessor :key

  def initialize
    @user_email = 'wkisielewicz@criticue.com'
    @admin_email = 'wkisielewicz@criticue.com'
    @license = 'spec\licenses\FB-S.edn'
    @friendly_name = 'test'
  end

  def create!
    ProtonApi::Subscription.create!(@user_email, @admin_email, EDN.read(File.read(@license)), @friendly_name)
  end

  def destroy!
    # @id = @a.subscription_id
    # ProtonApi::Subscription.find("puri::subscription:#{@id}").destroy!
    system("proton-provision destroy -i #{@id}")
  end
end