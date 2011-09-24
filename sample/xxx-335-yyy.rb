require File.dirname(__FILE__) + '/../lib/utils'

dm = DeploymentManager.new(:release_number => "XXX-335",
                           :app_code => :xxx,
                           :target=> :yyy
                          )
dm.run do

  xsls = [
    {:src=>"#{some_src_path_a}/*.xsl",:dest=>"#{some_dest_path_a}"},
    {:src=>"#{some_src_path_b}/*.xsl",:dest=>"#{some_dest_path_b}"},
  ]

  deploy_component_files(:subsystem=>:aaa,
                        :component=>:bbb,
                        :items=>xsls)

  deploy_component_files(:subsystem=>:ddd,
                        :component=>:eee,
                        :items=>[
                         {:src=>"#{some_src_path_c}",:dest=>"#{some_dest_path_c}"}
                         ])

  [:ddd,:aaa,:ccc].each do |subsystem|
    deploy_component_jars(:subsystem=>subsystem,
                          :component=>:eee,
                          :items=>[
                            {:src=>"#{some_src_path_d}",:dest=>"#{some_dest_path_d}/#{some_zip_or_jar_file}"}
                           ])
  end

  
end

