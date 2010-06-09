require 'formula'

class Gsh < Formula
  url 'http://guichaz.free.fr/gsh/files/gsh-0.3.tar.gz'
  homepage 'http://guichaz.free.fr/gsh/'
  md5 '6b925fe21bb84606b47a9a29d1eb88fb'

# depends_on 'cmake'

#   depends_on 'python'

  PTH_CONTENT =<<-EOS
# Don't modify this file, it is automatically handled by homebrew
import site; site.addsitedir('__HOMEBREW_GSH_PATH__')
  EOS

  def site_packages 
    @site_packages ||= `python -c "from distutils.sysconfig import get_python_lib; print get_python_lib()"`.chomp
  end

  def install
    $stderr.puts "site_packages: #{site_packages}"

    dest = lib

    mkdir_p dest
    ENV.append('PYTHONPATH', dest, ':')

    system(*%W[python setup.py install --prefix=#{prefix} --install-lib=#{dest}])

    pth_data = PTH_CONTENT.sub(/__HOMEBREW_GSH_PATH__/, dest)

    pth = Pathname.new("#{site_packages}/gsh.pth")
    ohai "Writing #{pth} to enable gsh"

    pth.unlink if pth.exist?
    pth.write(pth_data)
  end
end
