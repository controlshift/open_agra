task create_org_views: :environment do
  Organisation.all.each do |organisation|

    puts "-----------Organisation: #{organisation.name}---------------"

    %w(users petitions signatures).each do |table|
      view_name = "#{table}_#{organisation.slug}"
      drop_view_if_exist(view_name)
      puts "  - Create view #{view_name}"

      create_view_sql = self.send("create_view_sql_for_#{table}", view_name, organisation)
      ActiveRecord::Base.connection.execute(create_view_sql)
    end
  end
end

private

def drop_view_if_exist(view_name)
  drop_view_sql = "DROP VIEW IF EXISTS #{view_name}"
  ActiveRecord::Base.connection.execute(drop_view_sql)
end

def create_view_sql_for_users(view_name, organisation)
   columns_to_exclude = %w[encrypted_password reset_password_token confirmation_token]
   create_view_sql = "CREATE VIEW #{view_name} AS "
   create_view_sql << "SELECT "
   create_view_sql << column_names(User, columns_to_exclude)
   create_view_sql << " FROM users "
   create_view_sql << "WHERE organisation_id = #{organisation.id};"  
   create_view_sql              
end

def create_view_sql_for_petitions(view_name, organisation)
   columns_to_exclude = %w[token]
   create_view_sql = "CREATE VIEW #{view_name} AS "
   create_view_sql << "SELECT "
   create_view_sql << column_names(Petition, columns_to_exclude)
   create_view_sql << " FROM petitions "
   create_view_sql << "WHERE organisation_id = #{organisation.id};"    
   create_view_sql            
end

def create_view_sql_for_signatures(view_name, organisation)
   columns_to_exclude = %w[token]
   create_view_sql = "CREATE VIEW #{view_name} AS "
   create_view_sql << "SELECT "
   create_view_sql << column_names(Signature, columns_to_exclude)
   create_view_sql << " FROM signatures "
   create_view_sql << " WHERE id IN (SELECT id FROM petitions WHERE organisation_id = #{organisation.id})"
   create_view_sql
end

def column_names(active_record_klass, columns_to_exclude = [])
  (active_record_klass.column_names - columns_to_exclude).join(',')
end