require 'spec_helper'

describe MappingsController do
  render_views

  context "for unauthenticated user" do
    describe "GET #index" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
        get :index
      end
    end

    describe "GET #show" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
        get :show, id: create(:mapping).id
      end
    end

    describe "GET #new" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
        get :new, attachment_id: create(:attachment).id
      end
    end

    describe "POST #create" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
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
          response.should render_template(:index)
        end

        it "reveals authorized mappings" do
          get :index
          assigns[:mappings].should == [@authorized_mapping]
        end
      end

      describe "GET #show" do
        context "unauthorized" do
          it "triggers access_denied" do
            controller.should_receive(:access_denied)
            get :show, id: @unauthorized_mapping.id
          end
        end

        context "authorized" do
          it "renders show template" do
            get :show, id: @authorized_mapping.id
            response.should render_template(:show)
          end

          it "reveals requested mapping" do
            get :show, id: @authorized_mapping.id
            assigns[:mapping].should == @authorized_mapping
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
            controller.should_receive(:access_denied)
            get :new, attachment_id: @unauthorized_attachment.id
          end
        end

        context "authorized" do
          it "renders new template" do
            get :new, attachment_id: @authorized_attachment.id
            response.should render_template(:new)
          end

          it "reveals new mapping" do
            get :new, attachment_id: @authorized_attachment.id
            assigns[:mapping].should_not be_nil
          end
        end
      end

      describe "POST #create" do
        context "unauthorized" do
          it "triggers access_denied" do
            controller.should_receive(:access_denied)
            post :create, attachment_id: @unauthorized_attachment.id, mapping: {}
          end
        end

        context "authorized" do
          let(:mapping_params) {
            {
              "import_type" => "line_item",
              "document_type" => "invoice",
              "mapping_elements_attributes"=>{"0"=>{"source"=>"2", "target"=>"email", "model_to_import" => "line_item"}, "1"=>{"source"=>"1", "target"=>"organisation", "model_to_import" => "line_item"}}
            }
          }

          it "creates new mapping" do
            lambda {
              post :create, attachment_id: @authorized_attachment.id, mapping: mapping_params
            }.should change(Mapping, :count).by(1)
          end

          it "reveals new mapping" do
            post :create, attachment_id: @authorized_attachment.id, mapping: mapping_params
            assigns[:mapping].should_not be_nil
          end

          it "sets mapping user_id" do
            post :create, attachment_id: @authorized_attachment.id, mapping: mapping_params
            assigns[:mapping].user_id.should == @user_id
          end

          it "sets mapping company_id" do
            post :create, attachment_id: @authorized_attachment.id, mapping: mapping_params
            assigns[:mapping].company_id.should == @company_id
          end

          it "assigns mapping to the attachment" do
            post :create, attachment_id: @authorized_attachment.id, mapping: mapping_params
            @authorized_attachment.reload
            @authorized_attachment.mapping.should == assigns[:mapping]
          end

          it "redirects to new attachment import" do
            post :create, attachment_id: @authorized_attachment.id, mapping: mapping_params
            response.should redirect_to(new_attachment_import_url(@authorized_attachment))
          end
        end
      end
    end
  end
end
