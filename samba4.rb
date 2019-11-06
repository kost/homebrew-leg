# Documentation: https://docs.brew.sh/Formula-Cookbook.html
#                http://www.rubydoc.info/github/Homebrew/brew/master/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Samba4 < Formula
  desc "SMB/CIFS file, print, and login server for UNIX"
  homepage "https://www.samba.org/"
  url "https://download.samba.org/pub/samba/samba-4.7.12.tar.gz"
  sha256 "0e9c386bc32983452c5dcafdee561f37e43a411ac1919c864404e6177b1aaf4a"

  # conflicts_with "talloc", :because => "both install `include/talloc.h`"
  conflicts_with "samba", :because => "both install samba server/client"
  conflicts_with "samba3", :because => "both install samba server/client"

  depends_on "gnutls"

  patch :DATA

  env :std

  def install
    # ENV.deparallelize
    ENV.delete('CFLAGS')
    ENV.delete('CXXFLAGS')
    ENV.delete('LDFLAGS')

    system "./configure",
			  "--without-acl-support",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-configdir=#{prefix}/etc"
    system "make"
    system "make", "install" # if this fails, try separate make/make install steps

    # Install basic example configuration
    mkdir_p "#{prefix}/etc"
    inreplace "examples/smb.conf.default" do |s|
      s.gsub! "/usr/local/samba/var/log.%m", "#{prefix}/var/log/samba/log.%m"
    end
    (prefix/"etc").install "examples/smb.conf.default" => "smb.conf"

    Dir["#{lib}/private/*[0-9].[0-9]*"].each do |filelib|
      if not File.stat(filelib).symlink? then
        basef=File.basename(filelib)
        stripfilename=basef.gsub(/[0-9.]*.dylib/,'.dylib')
	stripfilename4=basef.gsub(/[0-9.]*.dylib/,'4.dylib')
        # puts "#{lib}/private/#{basef} => #{lib}/private/#{stripfilename}"
        ln_sf "#{lib}/private/#{basef}", "#{lib}/private/#{stripfilename}"
	ln_sf "#{lib}/private/#{basef}", "#{lib}/private/#{stripfilename4}"
      end
    end
  end

  test do
    system bin/"eventlogadm", "-h"
  end
end
__END__

diff -ur samba-4.7.3/source4/torture/local/nss_tests.c samba-4.7.3-mod/source4/torture/local/nss_tests.c
--- samba-4.7.3/source4/torture/local/nss_tests.c	2017-07-04 12:05:26.000000000 +0200
+++ samba-4.7.3-mod/source4/torture/local/nss_tests.c	2017-11-22 09:40:40.000000000 +0100
@@ -343,6 +343,8 @@
 	char buffer[4096];
 	int ret;
 
+#ifdef HAVE_GETPWENT_R
+
 	torture_comment(tctx, "Testing setpwent\n");
 	setpwent();
 
@@ -379,6 +381,8 @@
 		*num_pwd_p = num_pwd;
 	}
 
+#endif /* HAVE_GETPWENT_R */
+
 	return true;
 }
 
@@ -541,6 +545,7 @@
 	char buffer[4096];
 	int ret;
 
+#ifdef HAVE_GETGRENT_R
 	torture_comment(tctx, "Testing setgrent\n");
 	setgrent();
 
@@ -576,6 +581,7 @@
 	if (num_grp_p) {
 		*num_grp_p = num_grp;
 	}
+#endif /* HAVE_GETGRENT_R */
 
 	return true;
 }
