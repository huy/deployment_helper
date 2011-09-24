require File.dirname(__FILE__) + '/../shell/windows_box'

WAS_PROFILE = "/usr/IBM/WebSphere/AppServer/profiles"

TEST_CONFIG =[ 
    {:site=>[:sit,:uat],:subsystem=>[:webtop,:internet],:instance=>1,:host=>'myhostaswsi33-man'},
    {:site=>[:sit,:uat],:subsystem=>[:webtop,:internet],:instance=>2,:host=>'myhostaswsi34-man'},
    {:site=>[:sit,:uat],:subsystem=>[:connect,:cube],:instance=>1,:host=>'myhostasfap31-man'},
    {:site=>[:sit,:uat],:subsystem=>[:connect,:cube],:instance=>2,:host=>'myhostasfap32-man'},

    {:site=>[:sit,:uat],:subsystem=>:fulfillment,:instance=>1, :host=>'myhostasfap33',:machine_type=>WindowsBox},
    {:site=>:sit,:subsystem=>:branch,:instance=>1, :host=>'myhostasfap61',:machine_type=>WindowsBox},
    {:site=>:uat,:subsystem=>:branch,:instance=>1, :host=>'myhostasfap62',:machine_type=>WindowsBox},

    {:site=>:sit,:subsystem=>[:webtop,:internet],:instance=>[1,2],:component=>:runtime,:location=>'/home/app/gui'},
    {:site=>:uat,:subsystem=>[:webtop,:internet],:instance=>[1,2],:component=>:runtime,:location=>'/home/app/guiUATNEW'},

    {:site=>:sit,:subsystem=>:connect,:instance=>[1,2],:component=>:runtime,:location=>'/home/app/service'},
    {:site=>:sit,:subsystem=>:cube,:instance=>[1,2],:component=>:runtime,:location=>'/home/app/core'},

    {:site=>:uat,:subsystem=>:connect,:instance=>[1,2],:component=>:runtime,:location=>'/home/app/service_a'},
    {:site=>:uat,:subsystem=>:cube,:instance=>[1,2],:component=>:runtime,:location=>'/home/app/core_a'},

    {:site=>:sit,:subsystem=>:fulfillment,:instance=>1,:component=>:runtime,:location=>'d$/service'},
    {:site=>:uat,:subsystem=>:fulfillment,:instance=>1,:component=>:runtime,:location=>'d$/service_a'},

    {:site=>[:sit,:uat],:subsystem=>:branch,:instance=>1,:component=>:runtime,:location=>'d$/app'},

    
]


