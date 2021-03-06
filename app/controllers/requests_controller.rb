class RequestsController < InheritedResources::Base
  before_filter :authenticate_admin_user!

  def create
    @request = Request.new(params[:request])
    @patient = Patient.find_or_create(params[:patient_phone_number], params[:patient_first_name], params[:patient_last_name], params[:patient_email])
    @request.patient = @patient
    create!
  end

  def sendout
  end

  def sendoutemail
  	email = params[:email_address]
    UserMailer.inventory_email(email).deliver  
    redirect_to(:action => "index", :notice => 'Email Inventory Sent out') 
  end

  def notifications
    @requests = Request.find(:all, :conditions => {:status => "requested"})
    @patients = @requests.collect {|r| r.patient}.uniq

    @with_emails = []
     @with_phones = []
 
    @patients.each do |patient|
      if patient.email.nil? or patient.email.blank?
        @with_phones << patient
      else
        @with_emails << patient
      end
    end
  end

  def sendoutnotifications
    @requests = Request.find(:all, :conditions => {:status => "requested"})
    @patient_emails = @requests.collect {|r| r.patient}.uniq.select {|p| !p.email.blank?}.collect {|p| p.email}

    @patient_emails.each do |email|
      UserMailer.notification_email(email).deliver
    end

    redirect_to(:action => "index", :notice => 'Notifitcaion Emails Sent out')
  end

  def index
    @requests = Request.find(:all, :conditions => {:status => "open"})
    @past_requests = Request.find(:all, :conditions => {:status => "requested"})+Request.find(:all, :conditions => {:status => "delivered"})
  end
end
