# Generated via
#  `rails generate hyrax:work Asset`
module Hyrax
  class AssetForm < Hyrax::Forms::WorkForm
    include ChildCreateButton
    include DisabledFields

    self.model_class = ::Asset
    # Remove terms that we don't want to be a part of the form.
    self.terms -= [:relative_path, :import_url, :date_created, :resource_type,
                   :creator, :contributor, :keyword, :license,
                   :rights_statement, :publisher, :language, :identifier,
                   :based_near, :related_url, :bibliographic_citation, :source,
                   :title, :description]

    # Add fields that we want to be required
    self.required_fields += [:titles_with_types, :descriptions_with_types]

    # Remove fields that we don't want to be required.
    self.required_fields -= [:creator, :keyword, :rights_statement, :title, :description]

    class_attribute :field_groups

    #removing id, created_at & updated_at from attributes
    admin_data_attributes = (AdminData.attribute_names.dup - ['id', 'created_at', 'updated_at']).map &:to_sym

    self.field_groups = {
      identifying_info: [:titles_with_types, :producing_organization, :local_identifier, :pbs_nola_code, :eidr_id, :asset_types, :dates_with_types, :descriptions_with_types],
      subject_info: [:genre, :topics, :subject, :spatial_coverage, :temporal_coverage, :audience_level, :audience_rating, :annotation],
      rights: [:rights_summary, :rights_link],
      credits: [:child_contributors],
      aapb_admin_data: admin_data_attributes
    }

    self.terms += (self.required_fields + field_groups.values.map(&:to_a).flatten).uniq

    def primary_terms
      []
    end

    def secondary_terms
      []
    end

    # These methods are necessary to prevent the form builder from blowing up.
    def title_type; end
    def title_value; end
    def description_type; end
    def description_value; end
    def date_type; end
    def date_value; end
    def save_type; end


    def disabled?(field)
      disabled_fields = self.disabled_fields.dup
      disabled_fields += self.field_groups[:aapb_admin_data] if current_ability.cannot?(:create, AdminData)
      disabled_fields.include?(field)
    end

    def self.multiple?(field)
      if [:child_contributors,:special_collection,:sonyci_id].include?(field.to_sym)
        true
      else
        super
      end
    end

    def expand_field_group?(group)
      #Get terms for a certian field group
      return true if group == :credits && model.members.map{ |member| member.class }.include?(Contribution)

      #Get terms for a certian field group
      return true if group == :aapb_admin_data && model.admin_data && !model.admin_data.empty?

      field_group_terms(group).each do |term|
        #Expand field group
        return true if !model.attributes[term.to_s].blank? || model.errors.has_key?(term)
      end
      false
    end

    def field_group_terms(group)
      group_terms = field_groups[group]
      if group == :identifying_info
        group_terms = field_groups[group] - [:titles_with_types, :descriptions_with_types]
        group_terms += [:title, :program_title, :episode_title, :episode_number, :segment_title, :raw_footage_title, :promo_title, :clip_title]
        group_terms += [:description, :episode_description, :segment_description, :raw_footage_description, :promo_description, :clip_description]
      end
      group_terms
    end

    def child_contributors
      child_contributions = []
      model.ordered_members.to_a.each do |member|
         if( member.class == Contribution )
            child_contributions << [member.id, member.contributor_role, member.contributor.first , member.portrayal, member.affiliation]
         end
       end
      child_contributions
    end

    def titles_with_types
      titles_with_types = []
      titles_with_types += model.title.map { |title| ['main', title] }
      titles_with_types += model.program_title.map { |title| ['program', title] }
      titles_with_types += model.episode_title.map { |title| ['episode', title] }
      titles_with_types += model.segment_title.map { |title| ['segment', title] }
      titles_with_types += model.raw_footage_title.map { |title| ['raw_footage', title] }
      titles_with_types += model.promo_title.map { |title| ['promo', title] }
      titles_with_types += model.clip_title.map { |title| ['clip', title] }
      titles_with_types
    end

    def descriptions_with_types
      descriptions_with_types = []
      descriptions_with_types += model.description.map { |description| ['main', description] }
      descriptions_with_types += model.program_description.map { |description| ['program', description] }
      descriptions_with_types += model.episode_description.map { |description| ['episode', description] }
      descriptions_with_types += model.segment_description.map { |description| ['segment', description] }
      descriptions_with_types += model.raw_footage_description.map { |description| ['raw_footage', description] }
      descriptions_with_types += model.promo_description.map { |description| ['promo', description] }
      descriptions_with_types += model.clip_description.map { |description| ['clip', description] }
      descriptions_with_types
    end

    def dates_with_types
      dates_with_types = []
      dates_with_types += model.date.map { |date| ['main', date] }
      dates_with_types += model.broadcast_date.map { |date| ['broadcast', date] }
      dates_with_types += model.created_date.map { |date| ['created', date] }
      dates_with_types += model.copyright_date.map { |date| ['copyright', date] }
      dates_with_types
    end

    def level_of_user_access
      if model.admin_data
        model.admin_data.level_of_user_access
      else
        ""
      end

    end

    def minimally_cataloged
      if model.admin_data
        model.admin_data.minimally_cataloged
      else
        ""
      end
    end

    def outside_url
      if model.admin_data
        model.admin_data.outside_url
      else
        ""
      end
    end

    def special_collection
      if model.admin_data
        Array(model.admin_data.special_collection)
      else
        []
      end
    end

    def transcript_status
      if model.admin_data
        model.admin_data.transcript_status
      else
        ""
      end
    end

    def sonyci_id
      if model.admin_data
        Array(model.admin_data.sonyci_id)
      else
        []
      end
    end

    def licensing_info
      if model.admin_data
        model.admin_data.licensing_info
      else
        ""
      end
    end

    # Augment the list of permmitted params to accept our fields that have
    # types associated with them, e.g. title + title type
    # NOTE: `super` in this case is HyraxEditor::Form.permitted_params
    def self.permitted_params
      super.tap do |permitted_params|
        permitted_params << { title_type: [] }
        permitted_params << { title_value: [] }
        permitted_params << { description_type: [] }
        permitted_params << { description_value: [] }
        permitted_params << { date_type: [] }
        permitted_params << { date_value: [] }
        permitted_params << { contributors: [[:id,:contributor_role,:contributor, :affiliation,:portrayal]] }
      end
    end
  end
end
