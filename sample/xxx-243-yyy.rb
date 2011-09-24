require File.dirname(__FILE__) + '/../lib/utils'

dm = DeploymentManager.new(:release_number => "XXX-243",
                           :app_code => :xxx,
                           :target=> :yyy
                          )
dm.run do

  zzz_jars = [
    {:src=>'ojdbc14.jar',:dest=>'system/build/extclasses/jars'},
  ]

  deploy_component_files(:subsystem=>:connect,
                          :component=>:runtime,
                          :items=>zzz_jars)
end
