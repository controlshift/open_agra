class AddTokenToSignatureAndPetitionModels < ActiveRecord::Migration
  def up
    [:signatures, :petitions].each do | tbl |
      add_column tbl, :token, :string
      add_index  tbl, :token, :unique => true
    end

    [Signature, Petition].each do |klass|
      klass.all.each do | o |
        o.create_token!
      end
    end
  end

  def down
    [:signatures, :petitions].each do | tbl |
      remove_index  tbl, :token
      remove_column tbl, :token
    end
  end
end
