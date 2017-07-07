require 'europeana/api'

namespace :solr do
  namespace :europeana do
    desc "Index records from Europeana from a file of record IDs"
    task :index => "index:work"
    
    namespace :index do
      task :work => :environment do
        if (!(ENV["EUROPEANA_IDS_FILE"]) || !(ENV["EUROPEANA_API_KEY"]))
          Rake::Task["solr:europeana:index:info"].execute
        else
          conn = Blacklight.default_index.connection 
          Europeana::API.api_key = ENV["EUROPEANA_API_KEY"]

          File.open(ENV["EUROPEANA_IDS_FILE"]) do |f|
            f.each_line do |id|
              doc = {}
              record = Europeana::API.record(id.strip)

              doc[:id] = "europeana-" + id.strip.partition("/")[2]
              doc[:agg_provider_sim] = 'Europeana'
              doc[:agg_provider_tsim] = 'Europeana'
              doc[:agg_data_provider_sim] = record[:object][:aggregations].first[:edmDataProvider][:def].first
              doc[:agg_data_provider_tsim] = doc[:agg_data_provider_sim]
              isa = record[:object][:aggregations].first[:edmIsShownAt]
              doc[:agg_is_shown_at_tsim] = CGI::parse(URI(isa).query)["shownAt"].first if !isa.nil?
              doc[:agg_preview_tsi] = record[:object][:europeanaAggregation][:edmPreview]

              proxy = record[:object][:proxies].first
              doc[:cho_creator_tsim] = proxy[:dcCreator][:def] unless proxy[:dcCreator].nil?
              doc[:cho_creator_display_tsim] = doc[:cho_creator_tsim]
        
              doc[:cho_contributor_tsim] = proxy[:dcContributor][:def] unless proxy[:dcContributor].nil?
              doc[:cho_contributor_display_tsim] = doc[:cho_contributor_display_tsim]
              doc[:author_display_tsim] = [doc[:cho_creator_display_tsim], doc[:cho_contributor_display_tsim]].flatten
              doc[:author_display_sim] = doc[:author_display_tsim]
              doc[:cho_identifier_tsim] = proxy[:dcIdentifier][:def] unless proxy[:dcIdentifier].nil?
              doc[:cho_is_part_of_tsim] = proxy[:dcIsPartOf][:def] unless proxy[:dcIsPartOf].nil?
              doc[:cho_subject_tsim] = proxy[:dcSubject][:en] unless proxy[:dcSubject].nil?
              doc[:cho_title_tsim] = record[:object][:title]
              doc[:cho_title_display_tsim] = doc[:cho_title_tsim]
              conn.add doc
            end
          end
          conn.commit
        end
      end

      task :info do
        
      end
    end
  end
end