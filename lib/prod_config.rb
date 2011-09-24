require File.dirname(__FILE__) + '/../shell/windows_box'

WAS_PROFILE = "/usr/IBM/WebSphere/AppServer/profiles"

PROD_CONFIG =[ 
  {:site=>:prod_tdc,:subsystem=>:webtop,:instance=>1,:host=>'myhostapwsi33-man'},
  {:site=>:prod_tdc,:subsystem=>:webtop,:instance=>2,:host=>'myhostapwsi34-man'},
  {:site=>:prod_tdc,:subsystem=>[:connect,:cube],:instance=>1,:host=>'myhostapfap31-man'},
  {:site=>:prod_tdc,:subsystem=>[:connect,:cube],:instance=>2,:host=>'myhostapfap32-man'},
  {:site=>:prod_tdc,:subsystem=>:fulfillment,:instance=>1,:host=>'myhostapfap33',:machine_type=>WindowsBox},
  {:site=>:prod_tdc,:subsystem=>:fulfillment,:instance=>2,:host=>'myhostapfap34',:machine_type=>WindowsBox},
  {:site=>:prod_tdc,:subsystem=>:branch,:instance=>1,:host=>'myhostapfap61',:machine_type=>WindowsBox},
  {:site=>:prod_tdc,:subsystem=>:branch,:instance=>2,:host=>'myhostapfap62',:machine_type=>WindowsBox},

  {:site=>:prod_odc,:subsystem=>:webtop,:instance=>1,:host=>'myhostbpwsi33-man'},
  {:site=>:prod_odc,:subsystem=>:webtop,:instance=>2,:host=>'myhostbpwsi34-man'},
  {:site=>:prod_odc,:subsystem=>[:connect,:cube],:instance=>1,:host=>'myhostbpfap31-man'},
  {:site=>:prod_odc,:subsystem=>[:connect,:cube],:instance=>2,:host=>'myhostbpfap32-man'},
  {:site=>:prod_odc,:subsystem=>:zengin,:instance=>1,:host=>'myhostbpfap35-man'},
  {:site=>:prod_odc,:subsystem=>:fulfillment,:instance=>1,:host=>'myhostbpfap33',:machine_type=>WindowsBox},
  {:site=>:prod_odc,:subsystem=>:fulfillment,:instance=>2,:host=>'myhostbpfap34',:machine_type=>WindowsBox},
  {:site=>:prod_odc,:subsystem=>:branch,:instance=>1,:host=>'myhostbpfap61',:machine_type=>WindowsBox},
  {:site=>:prod_odc,:subsystem=>:branch,:instance=>2,:host=>'myhostbpfap62',:machine_type=>WindowsBox},

  {:site=>[:prod_tdc,:prod_odc],:subsystem=>[:webtop,:internet],:instance=>[1,2],:component=>:runtime,:location=>'/home/myapp/gui'},

  {:site=>[:prod_tdc,:prod_odc],:subsystem=>:connect,:instance=>[1,2],:component=>:runtime,:location=>'/home/myapp/service'},

  {:site=>[:prod_tdc,:prod_odc],:subsystem=>:cube,:instance=>[1,2],:component=>:runtime,:location=>'/home/myapp/core'},

  {:site=>[:prod_tdc,:prod_odc],:subsystem=>:fulfillment,:instance=>[1,2],:component=>:runtime,:location=>'d$/service'},

  {:site=>[:prod_tdc,:prod_odc],:subsystem=>:branch,:instance=>[1,2],:component=>:runtime,:location=>'d$/flexcube'},

  {:site=>:prod_tdc,:subsystem=>:webtop,:component=>:interaction_manager,:instance=>[1,2],
   :location=>"#{WAS_PROFILE}/FCATPROFILE/installedApps/CCAPAWCELL01/some_app.ear/some_war.war"},
  {:site=>:prod_odc,:subsystem=>:webtop,:component=>:interaction_manager,:instance=>[1,2],
   :location=>"#{WAS_PROFILE}/FCATPROFILE/installedApps/CCAPBWCELL01/some_app.ear/some_war.war"},

]


