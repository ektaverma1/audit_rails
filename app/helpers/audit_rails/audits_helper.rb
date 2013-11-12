module AuditRails
  module AuditsHelper
    def add_to_audit(action_name=nil, controller_name=nil, user_name=nil, description=nil)
      if action_name == "login"
        if AuditRails::Audit.no_audit_entry_for_today?(action_name, user_name)
          AuditRails::Audit.create(action: action_name, 
            controller: controller_name || request.params[:controller], 
            user_name: user_name, 
            description: description,
            ip_address: request.remote_ip.to_s)
        end
      else
        AuditRails::Audit.create(action: action_name || request.params[:action],
          controller: controller_name || request.params[:controller],
          user_name: user_name, 
          description: description,
          ip_address: request.remote_ip.to_s)
      end
    end

    def active?(action_name)
      controller.action_name == action_name
    end

    def active_class(action_name)
      active?(action_name) ? 'active' : ''
    end
  end
end
