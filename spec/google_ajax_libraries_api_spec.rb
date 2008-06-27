require File.join(File.dirname(__FILE__), 'spec_helper')

describe "RPH::Google::AjaxLibraries" do
  before(:all) do
    @module = RPH::Google::AjaxLibraries
  end
  
  before(:each) do
    @helper = ActionView::Base.new
  end
  
  it "should be mixed into ActionView::Base" do
    ActionView::Base.included_modules.include?(RPH::Google::AjaxLibraries).should be_true
  end
  
  it "should respond to 'google_js_library_for()' helper" do
    ActionView::Base.new.should respond_to(:google_js_library_for)
  end
  
  it "should have a helper for each library" do
    @module::GOOGLE_LIBRARIES.keys.each do |library|
      ActionView::Base.new.should respond_to("google_#{library}")
    end
  end
  
  describe "errors" do    
    it "should raise MissingLibrary error if no library is passed" do
      @helper.google_js_library_for() rescue @module::MissingLibrary; true
    end
    
    it "should raise MissingLibrary error if only options are passed" do
      @helper.google_js_library_for(:version => '1.2.3') rescue @module::MissingLibrary; true
    end
    
    it "should raise InvalidLibrary error if a non-supported library is specified" do
      @helper.google_js_library_for(:yui) rescue @module::InvalidLibrary; true
    end
    
    it "should raise InvalidVersion error if a non-supported version is specified" do
      @helper.google_js_library_for(:jquery, :version => '0.0.0') rescue @module::InvalidVersion; true
    end
    
    it "should raise InvalidVersion error if a non-supported version is specified" do
      @helper.google_jquery(:version => '0.0.0') rescue @module::InvalidVersion; true
    end
  end
  
  describe "defaults" do
    it "should set a default version" do
      @helper.google_jquery.match(/(\d.\d.\d)/)
      $1.should_not be_nil
    end
    
    it "should set a default version to the highest supported version" do
      expected_max_jquery_version = @module::GOOGLE_LIBRARIES[:jquery].versions.max
      @helper.google_jquery.match(/(\d.\d.\d)/)
      expected_max_jquery_version.should eql($1)
    end
    
    it "should set the default to be compressed version" do
      @helper.google_jquery.include?('jquery.min.js').should be_true
    end
  end
  
  it "should allow library access via symbol or string" do
    libs = @module::GOOGLE_LIBRARIES
    libs[:jquery].should == libs['jquery']
  end
  
  it "should support multiple versions when using 'google_js_library_for()' helper" do
    @helper.google_js_library_for(:jquery, :version => '1.2.3').
      should eql("<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.2.3/jquery.min.js\" type=\"text/javascript\"></script>")
  end
  
  it "should support multiple versions when using 'google_<library>' helper" do
    @helper.google_jquery(:version => '1.2.3').
      should eql("<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.2.3/jquery.min.js\" type=\"text/javascript\"></script>")
  end
  
  it "should support uncompressed versions when using 'google_js_library_for()' helper" do
    @helper.google_js_library_for(:jquery, :uncompressed => true).
      should eql("<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.2.6/jquery.js\" type=\"text/javascript\"></script>")
  end
  
  it "should support uncompressed versions when using 'google_<library>' helper" do
    @helper.google_jquery(:uncompressed => true).
      should eql("<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.2.6/jquery.js\" type=\"text/javascript\"></script>")
  end
  
  it "should support multiple versions and uncompressed at once using 'google_js_library_for()' helper" do
    @helper.google_js_library_for(:jquery, :version => '1.2.3', :uncompressed => true).
      should eql("<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.2.3/jquery.js\" type=\"text/javascript\"></script>")
  end
  
  it "should support multiple versions and uncompressed at once using 'google_<library>' helper" do
    @helper.google_jquery(:version => '1.2.3', :uncompressed => true).
      should eql("<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.2.3/jquery.js\" type=\"text/javascript\"></script>")
  end
  
  it "should support multiple libraries at once" do
    @helper.google_js_library_for(:prototype, :scriptaculous, :jquery).
      should eql(
        "<script src=\"http://ajax.googleapis.com/ajax/libs/prototype/1.6.0.2/prototype.js\" type=\"text/javascript\"></script>\n" +
        "<script src=\"http://ajax.googleapis.com/ajax/libs/scriptaculous/1.8.1/scriptaculous.js\" type=\"text/javascript\"></script>\n" +
        "<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.2.6/jquery.min.js\" type=\"text/javascript\"></script>"
      )
  end
  
  it "should make the :version option irrelevent when loading multiple libraries at once" do
    @helper.google_js_library_for(:prototype, :scriptaculous, :jquery, :version => '1.2.3').
      should eql(
        "<script src=\"http://ajax.googleapis.com/ajax/libs/prototype/1.6.0.2/prototype.js\" type=\"text/javascript\"></script>\n" +
        "<script src=\"http://ajax.googleapis.com/ajax/libs/scriptaculous/1.8.1/scriptaculous.js\" type=\"text/javascript\"></script>\n" +
        "<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.2.6/jquery.min.js\" type=\"text/javascript\"></script>"
      )
  end
  
  it "should support uncompressed versions of all applicable when loading multiple libraries at once" do
    @helper.google_js_library_for(:prototype, :dojo, :jquery, :uncompressed => true).
      should eql(
        "<script src=\"http://ajax.googleapis.com/ajax/libs/prototype/1.6.0.2/prototype.js\" type=\"text/javascript\"></script>\n" + 
        "<script src=\"http://ajax.googleapis.com/ajax/libs/dojo/1.1.1/dojo/dojo.xd.js.uncompressed.js\" type=\"text/javascript\"></script>\n" + 
        "<script src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.2.6/jquery.js\" type=\"text/javascript\"></script>"
      )
  end
end