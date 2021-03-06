# Generated via
#  `rails generate hyrax:work EssenceTrack`

module Hyrax
  class EssenceTracksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    # Handle Child Work button and redirect to child work page
    include Hyrax::ChildWorkRedirect
    # Redirects away from controller#new if object does not have parent_id
    include Hyrax::RedirectNewAction

    self.curation_concern_type = ::EssenceTrack

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::EssenceTrackPresenter
  end
end
