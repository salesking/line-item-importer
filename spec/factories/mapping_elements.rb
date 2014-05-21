FactoryGirl.define do
  #data row will look like this ["Test organization", "Test", "male_user", "test_user1@email.com", "Herr", "1980-01-10"]
  factory :mapping_element do
    mapping
    source 0
    target 'number'
    model_to_import 'document'

    factory :fname_mapping_element do
      source '1,2'
      target 'first_name'
      conversion_type 'join'
    end

    factory :email_mapping_element do
      source 3
      target 'email'
    end

    factory :gender_mapping_element do
      source 4
      target 'gender'
      conversion_type 'enum'
      conversion_options  "{\"male\":\"Herr\",\" female\":\"Frau\"}"
    end

    factory :birthday_mapping_element do
      source 5
      target 'birthday'
      conversion_type 'date'
      conversion_options "{\"date\":\"%Y-%M-%d\"}"
    end

    factory :line_item_mapping_element do
      model_to_import 'line_item'
      source 1
      target 'name'

      factory :join_line_item_mapping_element do
        source '2,3'
        target 'description'
        conversion_type 'join'
      end
    end
  end
end
