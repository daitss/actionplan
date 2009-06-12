class ActionPlans < Application

  provides :xml, :html

  # GET /action_plans
  def index
    @action_plans = $plans
    render
  end

  # GET /action_plans/:id
  def show

    # Does the request make sense?
    raise BadRequest unless params[:id]

    plan = $plans.find do |p|
      p.format == CGI::unescape(params[:id]) &&
        p.format_version == params[:formatversion]
    end
    
    raise NotFound unless plan

    # Load the action plan
    @action_plan = plan

    case content_type
    when :xml
      display @action_plan
    when :html
      render @action_plan.to_html
    end

  end

end
