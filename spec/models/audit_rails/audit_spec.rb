require 'spec_helper'
describe AuditRails::Audit do
  describe ".no_audit_entry_for_today?" do
    it "returns true when there is no audit entry for a user for an action " do
      AuditRails::Audit.no_audit_entry_for_today?('login', 'John').should be_true
    end

    it "returns false when there is an audit entry for a user for an action to avoid duplicate entries (e.g. for login)" do
      audit = AuditRails::Audit.create!(:action => action = "login", :user_name => user = "John Smith")

      AuditRails::Audit.no_audit_entry_for_today?(action, user).should be_false
    end
  end

  describe ".in_range" do
    # Not testing ActiveRecord, but need to make sure in_range is present and implemented correctly
    before(:each) do
      audit_1 = AuditRails::Audit.create!(:action => action = "login", :user_name => user = "John Smith")
      audit_2 = AuditRails::Audit.create!(:action => action = "login", :user_name => user = "John Smith")
      audit_3 = AuditRails::Audit.create!(:action => action = "login", :user_name => user = "John Smith")

      audit_1.update_attribute('created_at', 2.days.ago)
      audit_2.update_attribute('created_at', 3.days.ago)
      audit_3.update_attribute('created_at', 5.days.ago)
    end

    it 'returns audits created in a given date range in string format' do
      AuditRails::Audit.in_range(4.days.ago.strftime('%Y-%m-%d'), 1.days.ago.strftime('%Y-%m-%d')).count.should == 2
    end

    it 'returns audits created in a given date range in date format' do
      AuditRails::Audit.in_range(4.days.ago, 1.days.ago).count.should == 2
    end

    it 'returns all audits when range is nil' do
      AuditRails::Audit.in_range(nil, nil).count.should == 3
    end
  end

  describe ".analysis_by_user_name" do
    it "returns users and count for all audits in the system" do
      john = "John Smith"
      fake = "Fake User"
      audit = 3.times{
        AuditRails::Audit.create!(:action => action = "Visit", :user_name => john)
        AuditRails::Audit.create!(:action => action = "Visit", :user_name => fake)
      }

      AuditRails::Audit.analysis_by_user_name.should == "[{\"user\":\"#{fake}\",\"count\":3},{\"user\":\"#{john}\",\"count\":3}]"
    end
  end

    describe ".analysis_by_page_views" do
    it "returns controller-action and count for all audits in the system" do
      john = "John Smith"
      fake = "Fake User"
      audit = 3.times{
        AuditRails::Audit.create!(:action => action = "visit", :user_name => john, :controller => 'home')
        AuditRails::Audit.create!(:action => action = "login", :user_name => fake, :controller => 'session')
      }

      AuditRails::Audit.analysis_by_page_views.should == "[{\"page\":\"0\",\"count\":0},{\"page\":\"home/visit\",\"count\":3},{\"page\":\"session/login\",\"count\":3}]"
    end
  end

end