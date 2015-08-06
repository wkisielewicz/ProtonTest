require 'rspec'
require '../generate_security_key'

describe 'Generate security key' do

  let(:gk) {GenerateKey.new(password)}
  it 'should generate key' do

    click_button 'Plik ratunkowy'

    click_button 'utw-rz-nowy-plik-ratunkowy-btn-primary-btn'

    fill_in 'admin-dashboard-encryption-wizard-data-config-encryption-passphrase1',       with: gk.password
    fill_in 'admin-dashboard-encryption-wizard-data-config-encryption-passphrase2',       with: gk.password
    click_button 'next-btn-primary-btn'
    click_button 'Utworz plik ratunkowy'
    check ('checkbox-admin-dashboard-encryption-wizard-data-config-encryption-generate-understand')
    check('checkbox-admin-dashboard-encryption-wizard-data-config-encryption-generate-accepted')
    click_button 'next-btn-primary-btn'
    click_button 'zako-cz-btn-primary-btn'
    expect(page).to have_content 'Success'
      end
  end




