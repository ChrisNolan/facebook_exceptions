# FacebookExceptions

class ActionController::CgiRequest
  
  def from_facebook?
    request_parameters.has_key? 'fb_sig'
  end
  
end

class ApplicationController < ActionController::Base

  def facebook_rescues_path(template_name)
    "#{File.dirname(__FILE__)}/../views/#{template_name}.fbml.erb"
  end

  def facebook_template_path_for_local_rescue(exception)
    facebook_rescues_path(rescue_templates[exception.class.name])
  end
             
  def rescue_action_locally(exception)
    if request.from_facebook?
        add_variables_to_assigns
        @template.instance_variable_set("@exception", exception)
        @template.instance_variable_set("@response_code", response_code_for_rescue(exception))
        @template.instance_variable_set("@rescues_path", File.dirname(facebook_rescues_path("stub")))
        @template.send(:assign_variables_from_controller)

        @template.instance_variable_set("@contents", 
          @template.render_file(facebook_template_path_for_local_rescue(exception), false))

        response.content_type = Mime::HTML
        render_file(facebook_rescues_path("layout"))
    else
      ActionController::Rescue::rescue_action_locally(exception)
    end
  end

end