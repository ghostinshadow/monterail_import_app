# frozen_string_literal: true

feature 'Operation`s import' do
  subject { page }

  describe 'operations#import' do
    before(:example) { visit operations_path }

    scenario 'able to visit import page' do
      expect(current_path).to eq('/operations')

      within('h3') do
        is_expected.to have_content('Import')
      end
      is_expected.to have_css('#import_data')
    end

    xscenario 'able to upload a file', js: true do
      attach_test_file
      click_button('Import operations')

      is_expected.to have_content('Imported successfully')
    end
  end

  def attach_test_file
    within('#import_data') do
      attach_file('import_data_file', csv_path)
    end
  end

  def csv_path
    Rails.root + 'test/fixtures/import_example.csv'
  end
end
