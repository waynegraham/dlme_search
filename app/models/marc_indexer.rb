$:.unshift './config'
class MarcIndexer < Blacklight::Marc::Indexer
  # this mixin defines lambda facotry method get_format for legacy marc formats
  include Blacklight::Marc::Indexer::Formats

  def initialize
    super

    settings do
      # type may be 'binary', 'xml', or 'json'
      provide "marc_source.type", "binary"
      # set this to be non-negative if threshold should be enforced
      provide 'solr_writer.max_skipped', -1
    end

    # Mapping reference: https://docs.google.com/spreadsheets/d/1BzZvDOf4fgas3TD21xF40lu2pk2XW0k2pTGJKIt6438/edit#gid=1906730566

    to_field "id", trim(extract_marc("001"), :first => true)
    to_field 'marc_display', get_xml
    to_field "text", extract_all_marc_values do |r, acc|
      acc.replace [acc.join(' ')] # turn it into a single string
    end
     
    to_field "cho_language_sim", marc_languages("008[35-37]:041a:041d:")
    to_field "cho_format_sim", get_format
    to_field "cho_format_tsim", get_format
    to_field "cho_identifier_tsim",  extract_marc('020a', :separator=>nil) do |rec, acc|
         orig = acc.dup
         acc.map!{|x| StdNum::ISBN.allNormalizedValues(x)}
         acc << orig
         acc.flatten!
         acc.uniq!
    end
     
    to_field 'cho_extent_tsim', extract_marc('300acf', :trim_punctuation => true)
     
    # Title fields
    #    primary title 
     
    to_field 'cho_title_tsim', extract_marc('245abnps')
    to_field 'cho_title_display_tsim', extract_marc('245a', :trim_punctuation => true, :alternate_script=>false)
    to_field 'cho_title_vern_display_tsim', extract_marc('245a', :trim_punctuation => true, :alternate_script=>:only)
     
    #    subtitle
     
    #to_field 'subtitle_t', extract_marc('245b')
    # to_field 'subtitle_display', extract_marc('245b', :trim_punctuation => true, :alternate_script=>false)
    # to_field 'subtitle_vern_display', extract_marc('245b', :trim_punctuation => true, :alternate_script=>:only)
     
    #    additional title fields
    to_field 'cho_alternate_tsim',
      extract_marc(%W{
        130#{ATOZ}
        240abcdefgklmnopqrs
        210ab
        222ab
        242abnp
        243abcdefgklmnopqrs
        246abcdefgnp
        247abcdefgnp
        700gklmnoprst
        710fgklmnopqrst
        711fgklnpst
        730abcdefgklmnopqrst
        740anp
      }.join(':'))

    # Series added entry
    to_field 'cho_is_part_of_tsim', extract_marc("440anpv:490av")
     
    to_field 'cho_title_sort', marc_sortable_title
     
    # Creator/contributor fields
     
    to_field 'cho_creator_tsim', extract_marc("100abcegqu:110abcdegnu:111acdegjnqu")
    to_field 'cho_creator_display_tsim', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}", :alternate_script=>false)
    to_field 'cho_creator_vern_display_tsim', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}", :alternate_script=>:only)
    to_field 'cho_contributor_tsim', extract_marc("700abcegqu:710abcdegnu:711acdegjnqu")
    to_field 'cho_contributor_display_tsim', extract_marc("700abcdq:710#{ATOZ}:711#{ATOZ}", :alternate_script=>false)
    to_field 'cho_contributor_vern_display_tsim', extract_marc("700abcdq:710#{ATOZ}:711#{ATOZ}", :alternate_script=>:only)
    to_field 'author_display_sim', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}:700abcdq:710#{ATOZ}:711#{ATOZ}", :alternate_script=>false)
    to_field 'author_display_tsim', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}:700abcdq:710#{ATOZ}:711#{ATOZ}", :alternate_script=>false)
    to_field 'author_vern_display_tsim', extract_marc("100abcdq:110#{ATOZ}:111#{ATOZ}:700abcdq:710#{ATOZ}:711#{ATOZ}", :alternate_script=>:only)
     
    # JSTOR isn't an author. Try to not use it as one
    to_field 'author_sort', marc_sortable_author
     
    # Subject fields
    to_field 'cho_subject_tsim', extract_marc(%W(
      600#{ATOU}
      610#{ATOU}
      611#{ATOU}
      630#{ATOU}
      650abcde
      651ae
      653a:654abcde
    ).join(':'))
    to_field 'cho_has_type_tsim', extract_marc("600v:610v:611v:630v:650v:651v:654v:655abv")
    to_field 'cho_has_type_sim', extract_marc("600v:610v:611v:630v:650v:651v:654v:655abv")
    to_field 'subject_topic_facet', extract_marc("600abcdq:610ab:611ab:630aa:650aa:653aa:654ab:655ab", :trim_punctuation => true)
    to_field 'cho_temporal_sim',  extract_marc("650y:651y:654y:655y", :trim_punctuation => true)
    to_field 'cho_temporal_tsim',  extract_marc("650y:651y:654y:655y", :trim_punctuation => true)
    to_field 'cho_spatial_sim',  extract_marc("651a:650z", :trim_punctuation => true )
    to_field 'cho_spatial_tsim',  extract_marc("651a:650z", :trim_punctuation => true )
     
    # Publication fields
    to_field 'cho_publisher_tsim', extract_marc('260ab', :trim_punctuation => true)
    to_field 'cho_publisher_display_tsim', extract_marc('260ab', :trim_punctuation => true, :alternate_script=>false)
    to_field 'cho_publisher_vern_display_tsim', extract_marc('260ab', :trim_punctuation => true, :alternate_script=>:only)
    to_field 'cho_date_sim', marc_publication_date
    to_field 'cho_date_display_tsim', marc_publication_date

    # Notes
    to_field 'cho_description_tsim', extract_marc('520:500')
    to_field 'cho_provenance_tsim', extract_marc('561')

    # Provider links
    to_field 'agg_data_provider_sim', extract_marc('852ab')
    to_field 'agg_data_provider_tsim', extract_marc('852ab')
    to_field 'agg_provider_sim', extract_marc('852a', :trim_punctuation => true, :first=>true)
    to_field 'agg_provider_tsim', extract_marc('852a', :trim_punctuation => true, :first=>true)
    to_field('agg_is_shown_at_tsim') do |rec, acc|
      rec.fields('856').each do |f|
        case f.indicator2
        when '1'
          f.find_all{|sf| sf.code == 'u'}.each do |url|
            acc << url.value
          end
        end
      end
    end

    # # Call Number fields
    # to_field 'lc_callnum_display', extract_marc('050ab', :first => true)
    # to_field 'lc_1letter_facet', extract_marc('050ab', :first=>true, :translation_map=>'callnumber_map') do |rec, acc|
    #   # Just get the first letter to send to the translation map
    #   acc.map!{|x| x[0]}
    # end
    #
    # alpha_pat = /\A([A-Z]{1,3})\d.*\Z/
    # to_field 'lc_alpha_facet', extract_marc('050a', :first=>true) do |rec, acc|
    #   acc.map! do |x|
    #     (m = alpha_pat.match(x)) ? m[1] : nil
    #   end
    #   acc.compact! # eliminate nils
    # end

    # to_field 'lc_b4cutter_facet', extract_marc('050a', :first=>true)
     
    # URL Fields
     
    # notfulltext = /abstract|description|sample text|table of contents|/i


  end
end