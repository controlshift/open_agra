class ConditionalBooleanInput < SimpleForm::Inputs::BooleanInput
  # A boolean input field that also shows/hides fields with a particular css class.
  def input
    snippet = <<-html_snippet
      $(function() {
        var conditionalElements = $('.#{attribute_name}-conditional_boolean');
        adjustElements($('##{object_name}_#{attribute_name}'), conditionalElements);

        $('##{object_name}_#{attribute_name}').change(function(){
          var conditionalElements = $('.#{attribute_name}-conditional_boolean');
          adjustElements($(this), conditionalElements);
        });
      });

      function adjustElements(elem, elements){
          if( elem.is(':checked') ){
            elements.show();
          } else {
            elements.hide();
          }
      }

    html_snippet

    template.content_tag(:script, snippet.html_safe) + super
  end
end