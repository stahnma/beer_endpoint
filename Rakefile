require 'fileutils'

NAME='beer-endpoint'
PWD=`pwd`.strip!
SPEC_FILE="contrib/#{NAME}.spec"

RPM_DEFINES = " --define \"_specdir #{PWD}/SPECS\" --define \"_rpmdir #{PWD}/RPMS\" --define \"_sourcedir #{PWD}/SOURCES\" --define \" _srcrpmdir #{PWD}/SRPMS\" --define \"_builddir #{PWD}/BUILD\""
CHROOT="#{NAME}"

task :default => :tarball  do 
end


task :clean  do
  sh "rm -rf BUILD SOURCES SPECS SRPMS RPMS *.rpm *.tar.gz #{CHROOT} *.tgz *.deb"
end

task :dirs do
  dirs = [ 'BUILD', 'SPECS', 'SOURCES', 'RPMS', 'SRPMS' ] 
  dirs.each do |d|
    FileUtils.mkdir_p "#{PWD}//#{d}"
  end
  sh "mv *.tar.gz SOURCES"
  sh "cp  contrib/#{NAME}.spec SPECS"
end

desc "Create a tarball of source in local directory"
task :tarball => :clean  do
  puts
  version=`grep ^Version contrib/*.spec | awk '{print $NF}'`.strip()
  cwd=`pwd`.strip()
  sh "mkdir -p /tmp/#{NAME}-#{version}/"
  sh "rsync -ax * /tmp/#{NAME}-#{version}/"
  sh "tar -C /tmp -p -c  -z --exclude=contrib/*.spec --exclude=Gemfile.lock --exclude=.project --exclude=.git --exclude=.gitignore -f  /tmp/#{NAME}-#{version}.tar.gz #{NAME}-#{version}"
  sh "mv /tmp/#{NAME}-#{version}.tar.gz . "
  puts "Tarball is #{NAME}-#{version}.tar.gz"
end

desc "Create a SRPM. (using md5 hash, not the new SHA1)"
task :srpm => [ :tarball , :dirs ] do
  unless File.exists?('/usr/bin/rpmbiuld-md5')
    warn "/usr/bin/rpmbuild-md5 command not found."
    exit 1
  end
  sh "rpmbuild-md5   #{RPM_DEFINES}  -bs #{SPEC_FILE}"
  sh "mv -f SRPMS/* ."
  sh "rm -rf BUILD SRPMS RPMS SPECS SOURCES"
end
