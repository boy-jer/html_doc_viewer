ActionController::Routing::SEPARATORS =  %w( / ; , ? ) #hack to escape '.' (period) in the routes

HtmlDocViewer::Application.routes.draw do
  root :to => 'documents#new'
  
  resources :documents do
    collection do
      post 'upload'
      get 'result'
      get 'display'
      get 'fetch_html'
      get 'fetch_image' #purely for testing sake
      get 'fetch_font' #purely for testing sake
      match '/fonts/:name' => 'documents#fetch_font'
      match '/:file/:img' => 'documents#fetch_image'
    end
  end

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  
end
