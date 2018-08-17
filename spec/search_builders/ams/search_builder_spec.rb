require 'rails_helper'
require_relative '../../../app/search_builders/ams/search_builder'

RSpec.describe AMS::SearchBuilder do
  let(:me) { create(:user) }

  let(:config) { CatalogController.blacklight_config }

  let(:scope) do
    double('The scope',
           blacklight_config: config,
           current_ability: Ability.new(me),
           current_user: me)
  end

  let(:builder) { described_class.new(scope).with(params_object) }
  let(:builder_params) { builder[:fq] }
  let(:after_date_raw) { "10/10/2010" }
  let(:before_date_raw) { "11/11/2011" }
  let(:date_query_format) { "%Y-%m-%dT%H:%M:%SZ" }
  let(:after_date) { DateTime.parse(after_date_raw.to_s).utc.strftime(date_query_format) }
  let(:before_date) { DateTime.parse(before_date_raw.to_s).utc.strftime(date_query_format) }
  let(:params_object) { ActionController::Parameters.new(
      'controller' => 'catalog',
      'action' => 'index') }


  describe '#apply_date_filter' do
    context 'when no dates are supplied' do
      it 'does not include any filters for date fields' do
        expect(builder_params).to_not include("date_drsim\:")
        expect(builder_params).to_not include("broadcast_date_drsim\:")
        expect(builder_params).to_not include("created_date_drsim\:")
        expect(builder_params).to_not include("copyright_date_drsim\:")
        # expect(builder_params).to_not include_after_date_filter
        # expect(builder_params).to_not include_date_range_filter
      end
    end

    context 'when the "exact" radio button is selected and when the first date is supplied' do
      before do
        params_object['exact_or_range'] = 'exact'
        params_object['after_date'] = after_date_raw
      end

      it 'adds parameters that filter results to records whose date matches the supplied parameter' do
        expect(builder_params).to include("date_drsim\:#{after_date}")
        expect(builder_params).to include("broadcast_date_drsim\:#{after_date}")
        expect(builder_params).to include("created_date_drsim\:#{after_date}")
        expect(builder_params).to include("copyright_date_drsim\:#{after_date}")
      end
    end

    context 'when the "range" radio button is selected' do
      before { params_object['exact_or_range'] = 'range' }

      context 'and when the "after_date" param is supplied' do
        before { params_object['after_date'] = after_date_raw }

        it 'adds parameters that filter results to records whose dates are after the supplied parameter' do
          expect(builder_params).to include("date_drsim\:[#{after_date} TO *]")
          expect(builder_params).to include("broadcast_date_drsim\:[#{after_date} TO *]")
          expect(builder_params).to include("created_date_drsim\:[#{after_date} TO *]")
          expect(builder_params).to include("copyright_date_drsim\:[#{after_date} TO *]")
        end
      end

      context 'and when the "before_date" param is supplied' do
        before { params_object['before_date'] = before_date_raw }

        it 'adds parameters that filter results to records whose dates are before the supplied parameter' do
          expect(builder_params).to include("date_drsim\:[* TO #{before_date}]")
          expect(builder_params).to include("broadcast_date_drsim\:[* TO #{before_date}]")
          expect(builder_params).to include("created_date_drsim\:[* TO #{before_date}]")
          expect(builder_params).to include("copyright_date_drsim\:[* TO #{before_date}]")
        end
      end

      context 'and when both "after_date" and "before_date" are supplied' do
        before do
          params_object['after_date'] = after_date_raw
          params_object['before_date'] = before_date_raw
        end

        it 'adds parameters that filter results to records whose dates are between the supplied parameters' do
          expect(builder_params).to include("date_drsim\:[#{after_date} TO #{before_date}]")
          expect(builder_params).to include("broadcast_date_drsim\:[#{after_date} TO #{before_date}]")
          expect(builder_params).to include("created_date_drsim\:[#{after_date} TO #{before_date}]")
          expect(builder_params).to include("copyright_date_drsim\:[#{after_date} TO #{before_date}]")
        end
      end
    end
  end
end
