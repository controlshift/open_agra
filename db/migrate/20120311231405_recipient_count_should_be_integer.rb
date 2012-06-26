class RecipientCountShouldBeInteger < ActiveRecord::Migration
  def up
    execute "CREATE OR REPLACE FUNCTION pc_chartoint(chartoconvert character varying)
      RETURNS integer AS
    $BODY$
    SELECT CASE WHEN trim($1) SIMILAR TO '[0-9]+'
            THEN CAST(trim($1) AS integer)
        ELSE NULL END;

    $BODY$
      LANGUAGE 'sql' IMMUTABLE STRICT;"
    execute "ALTER TABLE petition_blast_emails ALTER COLUMN recipient_count DROP DEFAULT;"
    execute "ALTER TABLE petition_blast_emails ALTER COLUMN recipient_count TYPE integer USING pc_chartoint(recipient_count);"

  end

  def down
    change_column :petition_blast_emails, :recipient_count, :string
  end
end
