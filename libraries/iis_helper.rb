class Chef
	class IISPOSH
		class Common_code
      def self.ps_code(my_hash)
      #Sample output to generate
      #@{"//staticContent/mimeMap[@fileExtension='.currentExt']"="b"}
      #@{"a"="b" ; "c"="d"}
      powershell_string=""
      powershell_string+="@{"
      
      if my_hash != nil
        my_hash.each{|key ,val|
          if(key.is_a? String)
              raise "key:#{key} contains a double-quote which is not supported" if key.include?('"')
              powershell_string+="\"#{key}\"="
            else
            powershell_string+="#{key}="
           end
           
           if(val.is_a? String)
              raise "value:#{val} contains a double-quote which is not supported" if val.include?('"')
              powershell_string+="\"#{val}\" ; "
            else
            powershell_string+="#{val} ; "
           end
        }
      end
    
    powershell_string=powershell_string.strip().chomp(";")
    powershell_string+="}"
      
    Chef::Log.debug("Returning changed hash :#{powershell_string}")
    return powershell_string

    end
        
      def self.exit_code(script)
        result = Mixlibrary::Core::Shell.windows_script_out(:powershell,script)
        Chef::Log.debug "Powershell Output:"
        Chef::Log.debug(result.inspect)
        exit_status = result.exitstatus    
        Chef::Log.debug "Exit Code: #{exit_status}"
        return exit_status
      end	
      
      def self.binding_code(my_bindings)
        
        #This will take an array string that looks like this [["1"]] and transform to ["1"]
        #or from this  [["1"], [2]] to  ["1"],[2]
        bindings_string     = my_bindings.map     { |i| i.to_s }.join(",")
        
        
        #This needs to be special cased.  If there is one item we need the '(,' otherwise we dont need the comma.
        #Easiest way to do this is count if there is only one open bracket, we have the use case we need the comma
        appended_comma=""
        appended_comma="," if bindings_string.to_s.scan(/\[/).count ==1
        
        bindings_string		= "@(#{appended_comma}"+ bindings_string.to_s.gsub("[","(").gsub("]",")") +")"
        return bindings_string
      end
          
      end #class
    end #class
  end #class		
  
  
