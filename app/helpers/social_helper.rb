module SocialHelper
  def box_class
    facebook_login_enabled? ? 'small col-sm-8' : 'large col-sm-12' 
  end

  def label_class
    facebook_login_enabled? ? 'col-sm-12' : 'col-sm-4'
  end

  def input_class
    facebook_login_enabled? ? 'col-sm-12' : 'col-sm-8'
  end
end
