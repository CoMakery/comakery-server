module Views
  module Projects
    class Form < Views::Base
      needs :project

      def content
        row {
          form_for project do |f|
            with_errors(project, :title) {
              label {
                text "Title"
                f.text_field :title
              }
            }
            with_errors(project, :description) {
              label {
                text "Description"
                f.text_field :description
              }
            }
            f.submit "Create", class: buttonish(:small, :expand)
          end
        }
      end
    end
  end
end
