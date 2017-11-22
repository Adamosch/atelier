class Category < ActiveYaml::Base
  set_root_path "db/data"

  def  books
    ::Book.where(category_id: self.id)
  end
end