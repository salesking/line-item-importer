require 'spec_helper'

describe MappingsController do
  render_views

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
        get :show, id: create(:mapping).id
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
        post :create, attachment_id: create(:attachment).id, mapping: {}
      end
    end
  end

  context "for authenticated user" do
    before(:each) do
      @user_id = 'attachments-user'
      @company_id = 'attachments-company'
      user_login(user_id: @user_id, company_id: @company_id)
    end

    context "with existing mappings" do
      before(:each) do
        @authorized_mapping = create(:mapping, company_id: @company_id)
        @unauthorized_mapping = create(:mapping, company_id: 'another-company')
        MappingElement.any_instance.stub(:source_as_string).and_return(:some_string)
      end

      describe "GET #index" do
        it "renders index template" do
          get :index
          expect(response).to render_template(:index)
        end

        it "reveals authorized mappings" do
          get :index
          expect(assigns[:mappings]).to eq [@authorized_mapping]
        end
      end

      describe "GET #show" do
        context "unauthorized" do
          it "triggers access_denied" do
            expect(controller).to receive(:access_denied)
            get :show, id: @unauthorized_mapping.id
          end
        end

        context "authorized" do
          it "renders show template" do
            get :show, id: @authorized_mapping.id
            expect(response).to render_template(:show)
          end

          it "reveals requested mapping" do
            get :show, id: @authorized_mapping.id
            expect(assigns[:mapping]).to eq @authorized_mapping
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

          it "reveals new mapping" do
            get :new, attachment_id: @authorized_attachment.id
            expect(assigns[:mapping]).not_to be_nil
          end
        end
      end

      describe "POST #create" do
        context "unauthorized" do
          it "triggers access_denied" do
            expect(controller).to receive(:access_denied)
            post :create, attachment_id: @unauthorized_attachment.id, mapping: {}
          end
        end

        context "authorized" do
          let(:mapping_params) {
            {
              "import_type" => "line_item",
              "document_type" => "invoice",
              "document_id" => "",
              "mapping_elements_attributes"=>{"0"=>{"source"=>"2", "target"=>"email", "model_to_import" => "line_item"}, "1"=>{"source"=>"1", "target"=>"organisation", "model_to_import" => "line_item"}}
            }
          }

          it "creates new mapping" do
            expect(lambda {
              post :create, attachment_id: @authorized_attachment.id, mapping: mapping_params
            }).to change(Mapping, :count).by(1)
          end

          it "reveals new mapping" do
            post :create, attachment_id: @authorized_attachment.id, mapping: mapping_params
            expect(assigns[:mapping]).not_to be_nil
          end

          it "sets mapping user_id" do
            post :create, attachment_id: @authorized_attachment.id, mapping: mapping_params
            expect(assigns[:mapping].user_id).to eq @user_id
          end

          it "sets mapping company_id" do
            post :create, attachment_id: @authorized_attachment.id, mapping: mapping_params
            expect(assigns[:mapping].company_id).to eq @company_id
          end

          it "assigns mapping to the attachment" do
            post :create, attachment_id: @authorized_attachment.id, mapping: mapping_params
            @authorized_attachment.reload
            expect(@authorized_attachment.mapping).to eq assigns[:mapping]
          end

          it "redirects to new attachment import" do
            post :create, attachment_id: @authorized_attachment.id, mapping: mapping_params
            expect(response).to redirect_to(new_attachment_import_url(@authorized_attachment))
          end
        end
      end

      describe "GET #check_document" do
        before(:each) do
          @document_draft = double(id: "bJxojstGqr5iaaabxfpGMl", status: "draft")
          @document_no_draft = double(id: "bWJyFsw1ir5jBdabxfpGMl", status: "no_draft")

          Mapping.any_instance.stub(:check_if_document_is_present_and_is_draft).and_return true
          @mapping_with_document_id = create(:mapping, company_id: 'another-company', document_id: "bJxojstGqr5iaaabxfpGMl", document_type: 'invoice')
        end
        
        context "document is draft" do
          it "checks a related document" do
            Sk::Invoice.stub(:find).and_return @document_draft
            get :check_document, format: :json, id: @authorized_attachment.id, mapping_id: @mapping_with_document_id.id
            expect(response).to be_success
            expect(response.body).to eq "{}"
          end
        end

        context "document is no draft" do
          it "checks a related document" do
            Sk::Invoice.stub(:find).and_return @document_no_draft
            get :check_document, format: :json, id: @authorized_attachment.id, mapping_id: @mapping_with_document_id.id
            resp_hsh = ActiveSupport::JSON.decode(response.body)
            expect(resp_hsh["msg"]).to include("no_draft")
          end
        end

        context "document does not exist anymore" do
          it "handles error correctly" do
            Sk::Invoice.stub(:find).and_return nil
            get :check_document, format: :json, id: @authorized_attachment.id, mapping_id: @mapping_with_document_id.id
            expect(response.body).to eq "{}"
          end
        end
      end
    end
  end
end
