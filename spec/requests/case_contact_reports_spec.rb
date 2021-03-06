require "rails_helper"

RSpec.describe "/case_contact_reports", type: :request do
  let!(:case_contact) { create(:case_contact) }

  before do
    travel_to Time.local(2020,1,1)
    sign_in user
  end
  after { travel_back }

  describe "GET /case_contact_reports" do
    context "as volunteer" do
      let(:user) { create(:volunteer) }

      it "cannot view reports" do
        get case_contact_reports_url(format: :csv)
        expect(response).to redirect_to root_path
      end
    end

    shared_examples "can view reports" do
      context "with start_date and end_date" do
        let(:case_contact_report_params) {
          {
            start_date: 1.month.ago,
            end_date: Date.today
          }
        }

        it "renders a csv file to download" do
          get case_contact_reports_url(format: :csv), params: case_contact_report_params

          expect(response).to be_successful
          expect(
            response.headers["Content-Disposition"]
          ).to include 'attachment; filename="case-contacts-report-1577836800.csv'
        end
      end

      context "without start_date and end_date" do
        it "renders a csv file to download" do
          get case_contact_reports_url(format: :csv)

          expect(response).to be_successful
          expect(
            response.headers["Content-Disposition"]
          ).to include 'attachment; filename="case-contacts-report-1577836800.csv'
        end
      end
    end

    context "as supervisor" do
      it_behaves_like "can view reports" do
        let(:user) { create(:supervisor) }
      end
    end

    context "as casa_admin" do
      it_behaves_like "can view reports" do
        let(:user) { create(:casa_admin) }
      end
    end
  end
end
