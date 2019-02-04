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
    @user_email = 'mymail'
    @admin_email = 'usermail'
    @license = 'spec\licenses\FB-S.edn'
    @friendly_name = 'wioletta_automate_test'
  end


  def create!
    ProtonApi::Subscription.create!(@user_email, @admin_email, EDN.read(File.read(@license)), @friendly_name, @options)
  end

  def destroy!
     @id = @a.subscription_id
     ProtonApi::Subscription.find("puri::subscription:#{@id}").destroy!
    system("proton-provision destroy -i #{@id}")
  end
end

class Firebird_Variables

  attr_accessor :gbak_path, :isql_path, :full_path, :login, :password_firebird_database, :wrong_password, :security_password

  def initialize (gbak_path, isql_path, full_path, login, password, wrong_password,security_password)
    @gbak_path = 'C:\Program Files\Firebird\Firebird_2_5\bin\gbak.exe'
    @isql_path = 'C:\Program Files\Firebird\Firebird_2_5\bin\isql.exe'
    @full_path= 'C:\Program Files\Firebird\Firebird_2_5\examples\empbuild\EMPLOYEE.FDB'
    
    #using default Firebird login
    @login='SYSDBA'
    @password_firebird_database= 'masterkey'
    @wrong_password='pass'
    @security_password='test'

  end

end

