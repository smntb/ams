require 'rails_helper'
include Warden::Test::Helpers

RSpec.feature 'Create and Validate Asset', js: true do
  context 'Create adminset, create asset' do
    let(:admin_user) { create :admin_user }
    let!(:user_with_role) { create :user_with_role, role_name: 'user' }
    let!(:admin_set) { create :admin_set, title: ["Test Admin Set"] }

    let!(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(admin_set_id: admin_set.id) }
    let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

    let(:asset_attributes) do
      { title: "My Test Title", description: "My Test Description", broadcast: "04/02/2018", created: '04/02/2018', date: '04/02/2018', copyright_date: '04/02/2018',
        episode_number: 'EP#11', spatial_coverage: 'My Test Spatial coverage', temporal_coverage: 'My Test Temporal coverage', audience_level: 'My Test Audience level',
        audience_rating: 'My Test Audience rating', annotiation: 'My Test Annotiation', rights_summary: 'My Test Rights summary', rights_link: 'http://somerightslink.com/testlink' }
    end

    scenario 'Create and Validate Asset, Search asset' do
      Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
      Hyrax::PermissionTemplateAccess.create!(
        permission_template_id: permission_template.id,
        agent_type: 'group',
        agent_id: 'user',
        access: 'deposit'
      )
      # Login role user to create asset
      login_as(user_with_role)

      # create asset
      visit '/'
      click_link "Share Your Work"
      choose "payload_concern", option: "Asset"
      click_button "Create work"

      expect(page).to have_content "Add New Asset"

      click_link "Files" # switch tab
      expect(page).to have_content "Add files"
      expect(page).to have_content "Add folder"

      # validate metadata with errors
      page.find("#required-metadata")[:class].include?("incomplete")

      click_link "Descriptions" # switch tab
      fill_in('Title', with: asset_attributes[:title])
      fill_in('Description', with: asset_attributes[:description])

      # validated metadata without errors
      page.find("#required-metadata")[:class].include?("complete")

      click_link "Additional fields" # additional metadata

      fill_in('Broadcast', with: asset_attributes[:broadcast])
      fill_in('Created', with: asset_attributes[:created])
      fill_in('Date', with: asset_attributes[:date])
      fill_in('Copyright date', with: asset_attributes[:copyright_date])
      fill_in('Episode number', with: asset_attributes[:episode_number])
      fill_in('Spatial coverage', with: asset_attributes[:spatial_coverage])
      fill_in('Temporal coverage', with: asset_attributes[:temporal_coverage])
      fill_in('Audience level', with: asset_attributes[:audience_level])
      fill_in('Audience rating', with: asset_attributes[:audience_rating])
      fill_in('Annotiation', with: asset_attributes[:annotiation])
      fill_in('Rights summary', with: asset_attributes[:rights_summary])
      fill_in('Rights link', with: asset_attributes[:rights_link])

      click_link "Relationships" # define adminset relation
      find("#asset_admin_set_id option[value='#{admin_set.id}']").select_option

      # set it public
      find('body').click
      choose('asset_visibility_open')
      expect(page).to have_content('Please note, making something visible to the world (i.e. marking this as Public) may be viewed as publishing which could impact your ability to')

      click_on('Save')
      sleep(30)

      visit '/'
      find("#search-submit-header").click

      # expect assets is showing up
      expect(page).to have_content asset_attributes[:title]
      expect(page).to have_content asset_attributes[:broadcast]
      expect(page).to have_content asset_attributes[:created]
      expect(page).to have_content asset_attributes[:copyright_date]
      expect(page).to have_content asset_attributes[:episode_number]

      # open asset with detail show
      click_on(asset_attributes[:title])
      expect(page).to have_content asset_attributes[:broadcast]
      expect(page).to have_content asset_attributes[:created]
      expect(page).to have_content asset_attributes[:date]
      expect(page).to have_content asset_attributes[:copyright_date]
      expect(page).to have_content asset_attributes[:episode_number]
      expect(page).to have_content asset_attributes[:spatial_coverage]
      expect(page).to have_content asset_attributes[:temporal_coverage]
      expect(page).to have_content asset_attributes[:audience_level]
      expect(page).to have_content asset_attributes[:audience_rating]
      expect(page).to have_content asset_attributes[:annotiation]
      expect(page).to have_content asset_attributes[:rights_summary]
      expect(page).to have_content asset_attributes[:rights_link]

      exit
    end
  end
end