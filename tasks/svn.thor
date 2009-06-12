
class Svn < Thor
  
  desc "push", "push master to svn"
  method_options :verbose => :boolean
  def push

    r "git checkout master", "switching to master"
    git_commitish = r "git describe"
    
    svn_wc = r "mktemp -d -t svn-push"
    svn_wc.chomp!


    # checkout out from svn
    svn_url = "svn://tupelo.fcla.edu/shades/aps"
    Dir.chdir(svn_wc) { r "svn co #{svn_url} ." }
    
    # copy the files over
    %w{README Rakefile app autotest config merb public spec}.each do |f|
      FileUtils::cp_r f, svn_wc
    end

    FileUtils::cp_r File.join('gems', 'cache'), File.join(svn_wc, 'gems')
    
    Dir.chdir(svn_wc) do
      status = r "svn st"
      status.split("\n").each do |e|
        
        if e =~ /\?\s+(gems\/(?!cache))/
          puts e
          r "svn add #{$1}"
        end

      end
      
      r "svn ci -m 'taken from git #{git_commitish}'"
    end
    
  end
  
  private

  def r(command, desc=nil)

    desc ||= command
    
    puts "#{Time.now} #{desc}" if options[:verbose]
    output = `#{command}`
    
    if $? != 0
      puts "#{Time.now} '#{command}' exited with #{$?}"
      exit 1
    end

    output
    
  end
  
end


# svn diff -r 1699:1701 svn://tupelo.fcla.edu/shades/aps/public/plans | patch
