require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#destroy action" do 
    it "should successfully delete the gram if it exists in the database" do 
      gram = FactoryBot.create(:gram)
      delete :destroy, params: {id: gram.id} 
      expect(response).to redirect_to root_path
      gram = Gram.find_by_id(gram.id)
      expect(gram).to eq nil
    end
    it "should return a 404 error if the gram is not found" do 
      delete :destroy, params: {id: "NEVER-THERE"}
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#update action" do 
    it "should successfully update the gram if it exisits" do 
      gram = FactoryBot.create(:gram, message: 'Initial Value')
      patch :update, params: { id: gram.id, gram: { message: 'Changed' } }
      expect(response).to redirect_to root_path
      gram.reload
      expect(gram.message).to eq("Changed")
    end
    it "should return a 404 error if the gram is not found" do 
      patch :update, params: { id: 'YOLOSWAG', gram: { message: 'Changed' } }
      expect(response).to have_http_status(:not_found)
    end
    it "should render the edit form with an have_http_status :unprocessable_entity" do
      gram = FactoryBot.create(:gram, message: "Initial Value")
      patch :update, params: { id: gram.id, gram: { message: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      gram.reload
      expect(gram.message).to eq("Initial Value")
    end
  end

  describe "grams#edit action" do 
    it "should allow for a gram to be updated if it is found" do 
      gram = FactoryBot.create(:gram)
      get :edit, params: { id: gram.id }
      expect(response).to have_http_status(:success)
    end
    it "should return a 404 error if the gram is not found" do 
      get :edit, params: { id: 'GIBBERISH' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#show action" do 
    it "should show the page if the gram is found" do 
      gram = FactoryBot.create(:gram)
      get :show, params: { id: gram.id }
      expect(response).to have_http_status(:success)
    end
    it "should return a 404 error if the gram is not found" do
      get :show, params: { id: 'TACOCAT' }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#index action" do 
    it "should successfully show the page" do 
      get :index 
      expect(response).to have_http_status(:success)
    end 
  end 

  describe "grams#new action" do 
    it "should require users to be logged in" do 
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the form" do 
      user = FactoryBot.create(:user)
      sign_in user 

      get :new
      expect(response).to have_http_status(:success)
    end 
  end

  describe "grams#create action" do
    it "should require users to be logged in" do 
      post :create, params: { gram: { message: 'Hello' } } 
      expect(response).to redirect_to new_user_session_path
    end

    it "should succesfully save the gram to the database" do 
      user = FactoryBot.create(:user)
      sign_in user 

      post :create, params: { gram: { message: 'Hello!' } }
      expect(response).to redirect_to root_path 

      gram = Gram.last
      expect(gram.message).to eq("Hello!")
      expect(gram.user).to eq(user)
    end

    it "should properly deal with validation errors for blank messages" do
      user = FactoryBot.create(:user)
      sign_in user 

      gram_count = Gram.count 
      post :create, params: { gram: { message: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(gram_count).to eq 0
    end
  end
end
