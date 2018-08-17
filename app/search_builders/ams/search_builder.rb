module AMS
  class SearchBuilder < Hyrax::CatalogSearchBuilder

    # Add date filters to the processor chain.
    self.default_processor_chain += [:apply_date_filter]

    # Overrides Hyrax::FilterModels.
    def models
      [Asset]
    end

    # Adds date filters to the :fq of the solr params.
    def apply_date_filter(solr_params)
      if date_filters
        solr_params[:fq] ||= []
        solr_params[:fq] << "(#{date_filters.join(" OR ")})"
      end
      solr_params
    end

    ##
    # @example Adding a new step to the processor chain
    #   self.default_processor_chain += [:add_custom_data_to_query]
    #
    #   def add_custom_data_to_query(solr_parameters)
    #     solr_parameters[:custom] = blacklight_params[:user_value]
    #   end

    private

      # Returns the array of date filters
      def date_filters
        @date_filters ||= begin
          if filter_exact_date?
            if after_date
              date_field_names.map do |date_field|
                # Need to escape the date's colons for Solr query parsing when
                # not using dates within a range, i.e. square brackets.
                after_date_escaped = after_date.gsub(':', '\:')
                "#{date_field}:#{after_date_escaped}"
              end
            end
          elsif filter_date_range?
            if before_date || after_date
              range = "#{after_date || '*'} TO #{before_date || '*'}"
              date_field_names.map do |date_field|
                "#{date_field}:[#{range}]"
              end
            end
          end
        end
      end

      # Returns the 'before' date time formatted for a Solr query.
      def before_date
        @before_date ||= formatted_date(blacklight_params['before_date'])
      end

      # Returns the 'after' date time formatted for a Solr query.
      def after_date
        @after_date ||= formatted_date(blacklight_params['after_date'])
      end

      # Converts an unformatted date (as passed in via URL) to a date formatted
      # for a Solr query.
      def formatted_date(unformatted_date)
        DateTime.parse(unformatted_date.to_s).utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      rescue ArgumentError => e
        nil
      end

      def filter_exact_date?
        blacklight_params['exact_or_range'] == 'exact'
      end

      def filter_date_range?
        blacklight_params['exact_or_range'] == 'range'
      end

      def date_field_names
        ['date_drsim', 'broadcast_date_drsim', 'created_date_drsim', 'copyright_date_drsim']
      end
  end
end
