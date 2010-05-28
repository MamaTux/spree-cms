class PagesController < Spree::BaseController  
  resource_controller
  
  actions :show

  show.response do |wants|
    wants.html
  end
    
private
  def collection
    @collection ||= end_of_association_chain.publish.paginate :page => params[:page]
  end
  
  def object
    @object ||= end_of_association_chain.publish.find(param) unless param.nil?
    @object
  end
  

end 