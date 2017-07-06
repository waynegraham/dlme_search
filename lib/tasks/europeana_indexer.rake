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

              doc[:cho_dc_creator_tsim] = record[:object][:proxies].first[:dcCreator][:def]
              doc[:cho_dc_title_tsim] = record[:object][:title]
              doc[:cho_title_display_tsim] = doc[:cho_dc_title_tsim].first
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