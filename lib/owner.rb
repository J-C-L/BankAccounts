require 'csv'

module Bank
  class Owner
    attr_reader :id, :last_name, :first_name, :street_address, :city, :state

    @@all_owners = []

    def initialize(owner_hash)
      @id = owner_hash[:id]
      @last_name = owner_hash[:last_name]
      @first_name = owner_hash[:first_name]
      @street_address = owner_hash[:street_address]
      @city = owner_hash[:city]
      @state = owner_hash[:state]
      @@all_owners << self
    end


    def self.reset_all_owners_for_test
      @@all_owners = []
    end

    def self.read_csv
      CSV.open("./support/owners.csv").each do |owner|
        owner_id = owner[0].to_i
        owner_last_name = owner[1].to_s
        owner_first_name = owner[2].to_s
        owner_street_address = owner[3].to_s
        owner_city = owner[4].to_s
        owner_state = owner[5].to_s
        self.new(id:owner_id, last_name:owner_last_name, first_name:owner_first_name,  street_address:owner_street_address, city:owner_city, state:owner_state)
      end
    end

    def self.all
      @@all_owners
    end

    def self.find(id)
      found_accounts = @@all_owners.select {|owner| owner.id.to_i == id.to_i}
      raise ArgumentError.new("That account doesn't exist!")  if found_accounts[0]==nil
      return found_accounts[0]
    end
  end
end
