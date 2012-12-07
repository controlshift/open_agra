module Queries
  class OrgQuery < Query

    validates :query, presence: true
    validates :organisation, presence: true
    validate :query_format

    attr_accessor :query, :organisation
    attr_reader :result

    PREFIX_WHITE_LIST_TABLE_NAMES = %w(users petitions signatures)
    CONNECTION_TIMEOUT = 10000

    def execute
      @result = nil
      if valid?
        connection.transaction do
          connection.execute("set statement_timeout to #{CONNECTION_TIMEOUT}")
          result = connection.execute(limit_query)
          @result = OrgQueryResult.new(result.fields, result.values) if result
          raise ActiveRecord::Rollback
        end
      end
    end

    def self.limit_size
      50
    end

    def white_list_table_names
      PREFIX_WHITE_LIST_TABLE_NAMES.map { |name| name + '_' + organisation.slug }
    end

    private

    def limit_query
      "#{query} LIMIT #{Queries::OrgQuery.limit_size}"
    end

    def connection
      ActiveRecord::Base.connection
    end

    def query_format
      if query
        self.errors.add :query, 'Should start with a Select' unless query.match /^select/i
        self.errors.add :query, 'Should not contain ;' if query.match /;/
        self.errors.add :query, 'The table you want to access is not accessible.' unless querying_tables_allowed?
        self.errors.add :query, 'Should not contain any limit. The limit is #{Queries::OrgQuery.limit_size} by default.' if query.match /limit/i
      end
    end

    def querying_tables_allowed?
      allowed = true

      query_fragments.each do |q|
        tables_match_white_list = get_matches_in_query_fragment(q, regex_to_get_tables_which_match_white_list)
        all_tables = get_matches_in_query_fragment(q, regex_to_get_all_tables)

        allowed = (tables_match_white_list == all_tables) # fragments are allowed if the count of all table is equal to the count of allowed queries.
        break unless allowed
      end

      allowed
    end

    def query_fragments
      fragment = query
      qf = []
      # while there are any more FROM or JOIN statements
      while !fragment.scan(/join|from/i).empty?
        qf << fragment
        fragment = get_next_from_or_join_set(fragment, fragment =~ regex_to_get_tables_which_match_white_list)
      end
      qf
    end


    def get_next_from_or_join_set(fragment, index_of_match_tables)
      fragment.slice((index_of_match_tables || 0) + 'from'.length, fragment.length)
    end

    def regex_to_get_tables_which_match_white_list
      regex_to_get_tables_which_match(white_list_table_names.join('|'))
    end

    def regex_to_get_all_tables
      regex_to_get_tables_which_match('\w+')
    end

    def regex_to_get_tables_which_match(table_name_matcher)
      /(from|join)(\W+)(\b(#{table_name_matcher})\b((\W+)(as)(\W+)(\w+))*,(\W*))*\b(#{table_name_matcher})\b((\W+)(as)(\W+)(\w+))*/i
    end

    def get_matches_in_query_fragment(q, regex)
      query_match_data = q.match(regex)
      query_match_data ? query_match_data[0] :nil
    end
  end
end