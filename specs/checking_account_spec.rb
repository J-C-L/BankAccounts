require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/skip_dsl'
require_relative '../lib/checking_account'

#Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Because a CheckingAccount is a kind
# of Account, and we've already tested a bunch of functionality
# on Account, we effectively get all that testing for free!
# Here we'll only test things that are different.


describe "CheckingAccount" do

  describe "#initialize" do
    # Check that a CheckingAccount is in fact a kind of account
    it "Is a kind of Account" do
      account = Bank::CheckingAccount.new(12345, 100.0)
      account.must_be_kind_of Bank::Account
    end
  end

  describe "#withdraw" do

    #Since withdraw was overridden, must retest the basic functionality
    it "Requires a positive withdrawal amount" do
      start_balance = 100.0
      withdrawal_amount = -25.0
      account = Bank::CheckingAccount.new(1337, start_balance)
      proc {
        account.withdraw(withdrawal_amount)
      }.must_raise ArgumentError
    end


    it "Applies a $1 fee each time" do
      start_balance = 100.0
      withdrawal_amount = 25.0
      account = Bank::CheckingAccount.new(1337, start_balance)
      account.withdraw(withdrawal_amount)
      expected_balance = start_balance  - withdrawal_amount - 1
      account.balance.must_equal expected_balance
    end


    it "Doesn't modify the balance if the fee would put it negative" do
      start_balance = 100.0
      withdrawal_amount = 99.50
      account = Bank::CheckingAccount.new(1337, start_balance)
      updated_balance = account.withdraw(withdrawal_amount)
      # Both the value returned and the balance in the account
      # must be un-modified.
      updated_balance.must_equal start_balance
      account.balance.must_equal start_balance
    end
  end

  describe "#withdraw_using_check" do
    it "Reduces the balance" do
      start_balance = 100.0
      withdrawal_amount = 25.0
      account = Bank::CheckingAccount.new(1337, start_balance)

      account.withdraw_using_check(withdrawal_amount)

      expected_balance = start_balance  - withdrawal_amount
      account.balance.must_equal expected_balance
    end

    it "Returns the modified balance" do
      start_balance = 100.0
      withdrawal_amount = 25.0
      account = Bank::CheckingAccount.new(1337, start_balance)

      updated_balance = account.withdraw_using_check(withdrawal_amount)

      expected_balance = start_balance - withdrawal_amount
      updated_balance.must_equal expected_balance
    end

    it "Allows the balance to go down to -$10" do
      start_balance = 100.0
      withdrawal_amount = 110.0
      account = Bank::CheckingAccount.new(1337, start_balance)

      updated_balance = account.withdraw_using_check(withdrawal_amount)

      expected_balance = start_balance - withdrawal_amount
      updated_balance.must_equal expected_balance
    end

    it "Outputs a warning if the account would go below -$10" do
      start_balance = 100.0
      withdrawal_amount = 110.01
      account = Bank::CheckingAccount.new(1337, start_balance)
      proc {
        account.withdraw_using_check(withdrawal_amount)
      }.must_output(/.+/)
    end

    it "Doesn't modify the balance if the account would go below -$10" do
      start_balance = 100.0
      withdrawal_amount = 110.01
      account = Bank::CheckingAccount.new(1337, start_balance)
      updated_balance = account.withdraw_using_check(withdrawal_amount)
      # Both the value returned and the balance in the account
      # must be un-modified.
      updated_balance.must_equal start_balance
      account.balance.must_equal start_balance
    end

    it "Requires a positive withdrawal amount" do
      proc {
        Bank::Account.new(1337, -100.0)
      }.must_raise ArgumentError
    end

    it "Allows 3 free uses" do
      account = Bank::CheckingAccount.new(1337, 100)
      withdrawal_amount = 10
      3.times {account.withdraw_using_check(withdrawal_amount)}

      account.balance.must_equal 70
    end

    it "Applies a $2 fee after the third use" do
      account = Bank::CheckingAccount.new(1337, 100)
      withdrawal_amount = 10
      4.times {account.withdraw_using_check(withdrawal_amount)}

      account.balance.must_equal 58
    end
  end

  describe "#reset_checks" do
    it "Can be called without error" do
      account = Bank::CheckingAccount.new(1337, 100)
      account.reset_checks
    end

    it "Makes the next three checks free if less than 3 checks had been used" do
      account = Bank::CheckingAccount.new(1337, 100)
      withdrawal_amount = 10
      2.times {account.withdraw_using_check(withdrawal_amount)}
      account.reset_checks
      3.times {account.withdraw_using_check(withdrawal_amount)}
      account.balance.must_equal 50
    end

    it "Makes the next three checks free if more than 3 checks had been used" do
      account = Bank::CheckingAccount.new(1337, 100)
      withdrawal_amount = 10
      4.times {account.withdraw_using_check(withdrawal_amount)}
      account.reset_checks
      3.times {account.withdraw_using_check(withdrawal_amount)}
      account.balance.must_equal 28
    end

    it "Makes ONLY the next three checks free if more than 3 checks had been used" do
      account = Bank::CheckingAccount.new(1337, 100)
      withdrawal_amount = 10
      4.times {account.withdraw_using_check(withdrawal_amount)}
      account.reset_checks
      4.times {account.withdraw_using_check(withdrawal_amount)}
      account.balance.must_equal 16
    end

  end
end
