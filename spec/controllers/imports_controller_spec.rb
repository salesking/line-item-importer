require 'spec_helper'

describe ImportsController do
  render_views

  before :each do
    DataRows::DocumentDataRow.any_instance.stub(:create_document).and_return true
  end

  context "for unauthenticated user" do
    describe "GET #index" do
      it "triggers access_denied" do
        expect(controller).to receive(:access_denied)
        get :index
      end
    end
 
    describe "GET #show" do
      it "triggers access_denied" do
        expect(controller).to receive(:access_denied)
        get :show, id: create(:import).id
      end
    end

    describe "GET #new" do
      it "triggers access_denied" do
        expect(controller).to receive(:access_denied)
        get :new, attachment_id: create(:attachment).id
      end
    end

    describe "POST #create" do
      it "triggers access_denied" do
        expect(controller).to receive(:access_denied)
        post :create, attachment_id: create(:attachment).id
      end
    end
  end

  context "for authenticated user" do
    before :each do
      @user_id = 'attachments-user'
      @company_id = 'attachments-company'
      user_login(user_id: @user_id, company_id: @company_id)
    end

    context "with existing imports" do
      before(:each) do
        @authorized_import = create(:import, company_id: @company_id)
        @unauthorized_import = create(:import, company_id: 'another-company')
      end

      describe "GET #index" do
        it "renders index template" do
          get :index
          expect(response).to render_template(:index)
        end

        it "reveals authorized imports" do
          get :index
          expect(assigns[:imports]).to eq [@authorized_import]
        end
      end

      describe "GET #show" do
        context "unauthorized" do
          it "triggers access_denied" do
            expect(controller).to receive(:access_denied)
            get :show, id: @unauthorized_import.id
          end
        end

        context "authorized" do
          it "renders show template" do
            get :show, id: @authorized_import.id
            expect(response).to render_template(:show)
          end

          it "reveals requested import" do
            get :show, id: @authorized_import.id
            expect(assigns[:import]).to eq @authorized_import
          end
        end
      end
    end

    context "with attachment scope" do
      before(:each) do
        @authorized_attachment = create(:attachment, company_id: @company_id)
        @unauthorized_attachment = create(:attachment, company_id: 'another-company')
      end

      describe "GET #new" do
        context "unauthorized" do
          it "triggers access_denied" do
            expect(controller).to receive(:access_denied)
            get :new, attachment_id: @unauthorized_attachment.id
          end
        end

        context "authorized" do
          it "renders new template" do
            get :new, attachment_id: @authorized_attachment.id
            expect(response).to render_template(:new)
          end

          it "reveals new import" do
            get :new, attachment_id: @authorized_attachment.id
            expect(assigns[:import]).to_not be_nil
          end

          it "assigns new import with attachment" do
            get :new, attachment_id: @authorized_attachment.id
            expect(assigns[:import].attachment).to eq @authorized_attachment
          end
        end
      end

      describe "POST #create" do
        context "unauthorized" do
          it "triggers access_denied" do
            expect(controller).to receive(:access_denied)
            post :create, attachment_id: @unauthorized_attachment.id
          end
        end

        context "authorized" do
          it "creates new import" do
            expect(lambda {
              post :create, attachment_id: @authorized_attachment.id
            }).to change(Import, :count).by(1)
          end

          it "redirects to show" do
            post :create, attachment_id: @authorized_attachment.id
            expect(response).to redirect_to(import_url(assigns[:import]))
          end
        end
      end
    end
  end
end
