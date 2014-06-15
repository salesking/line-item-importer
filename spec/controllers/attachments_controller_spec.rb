require 'spec_helper'

describe AttachmentsController do
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
        get :show, id: create(:attachment).id
      end
    end

    describe "GET #new" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
        get :new
      end
    end

    describe "POST #create" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
        post :create, attachment: {}
      end
    end

    describe "PUT #update" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
        patch :update, id: create(:attachment).id, attachment: {}
      end
    end

    describe "DELETE #destroy" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
        delete :destroy, id: create(:attachment).id
      end
    end
  end

  context "for authenticaned user" do
    before(:each) do
      @user_id = 'attachments-user'
      @company_id = 'attachments-company'
      user_login(user_id: @user_id, company_id: @company_id)
      @authorized_attachment = create(:attachment, company_id: @company_id)
      @unauthorized_attachment = create(:attachment, company_id: 'another-company')
    end

    describe "GET #index" do
      it "renders index template" do
        get :index
        response.should render_template(:index)
      end

      it "reveals attachments authorized by company" do
        get :index
        assigns[:attachments].should == [@authorized_attachment]
      end
    end

    describe "GET #show" do
      context "authorized" do
        it "renders show template" do
          get :show, id: @authorized_attachment.id
          response.should render_template(:show)
        end

        it "reveals requested attachment" do
          get :show, id: @authorized_attachment.id
          assigns[:attachment].should == @authorized_attachment
        end
      end

      context "unauthorized" do
        it "triggers access_denied" do
          controller.should_receive(:access_denied)
          get :show, id: @unauthorized_attachment
        end
      end
    end

    describe "GET #new" do
      it "renders new template" do
        get :new
        response.should render_template(:new)
      end

      it "reveals new attachment with default column_separator and quote_character" do
        get :new
        assigns[:attachment].should_not be_nil
        assigns[:attachment].column_separator.should_not be_nil
        assigns[:attachment].quote_character.should_not be_nil
      end
    end

    describe "POST #create" do
      it "creates new attachment" do
        lambda {
          post :create, file: file_upload('test1.csv'), column_separator: ';', quote_character: '"', encoding: 'utf-8'
        }.should change(Attachment, :count).by(1)
      end

      it "reveals new attachment" do
        post :create, file: file_upload('test1.csv'), column_separator: ';', quote_character: '"', encoding: 'utf-8'
        assigns[:attachment].should_not be_nil
      end

      it "sets attachment user_id" do
        post :create, file: file_upload('test1.csv'), column_separator: ';', quote_character: '"', encoding: 'utf-8'
        assigns[:attachment].user_id.should == @user_id
      end

      it "sets attachment company_id" do
        post :create, file: file_upload('test1.csv'), column_separator: ';', quote_character: '"', encoding: 'utf-8'
        assigns[:attachment].company_id.should == @company_id
      end

      it "renders successful json response" do
        post :create, file: file_upload('test1.csv'), column_separator: ';', quote_character: '"', encoding: 'utf-8'
        response.content_type.should == "application/json"
        response.code.should == "200"
      end
    end

    describe "PUT #update" do
      context "unauthorized" do
        it "triggers access_denied" do
          controller.should_receive(:access_denied)
          patch :update, id: @unauthorized_attachment, attachment: {column_separator: ';'}
        end
      end

      context "with valid parameters" do
        it "reveals requested attachment" do
          patch :update, id: @authorized_attachment, attachment: {column_separator: '/'}
          assigns[:attachment].should == @authorized_attachment
        end

        it "updates attachment attributes" do
          patch :update, id: @authorized_attachment, attachment: {column_separator: '/', quote_character: '^'}
          assigns[:attachment].column_separator.should == '/'
          assigns[:attachment].quote_character.should == '^'
        end

        it "redirects to new attachment mapping on html request if mapping is not set" do
          patch :update, id: @authorized_attachment, attachment: {column_separator: ';', mapping_id: ''}
          response.should redirect_to(new_attachment_mapping_url(@authorized_attachment))
        end

        it "redirects to new attachment import on html request if mapping is set" do
          mapping = create(:mapping)
          patch :update, id: @authorized_attachment, attachment: {column_separator: ';', mapping_id: mapping.id}
          response.should redirect_to(new_attachment_import_url(@authorized_attachment))
        end
        it "reneders successful json response on js request" do
          patch :update, id: @authorized_attachment, attachment: {column_separator: ';'}, format: 'js'
          response.code.should == "200"
        end
      end

      context "with invalid parameters" do
        it "reveals requested attachment" do
          patch :update, id: @authorized_attachment, attachment: {column_separator: ''}
          assigns[:attachment].should == @authorized_attachment
        end

        it "renders new template on html request" do
          patch :update, id: @authorized_attachment, attachment: {column_separator: ''}
          response.should render_template(:new)
        end

        it "reneders successful json response on js request" do
          patch :update, id: @authorized_attachment, attachment: {column_separator: ''}, format: 'js'
          response.code.should == "200"
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested attachment" do
        expect {
          delete :destroy, id: @authorized_attachment.id
        }.to change(Attachment, :count).by(-1)
      end

      it "redirects to the attachments list after destroying the requested attachment" do
        delete :destroy, id: @authorized_attachment.id
        response.should redirect_to(attachments_path)
      end
    end

  end
end
