# Documentation: https://docs.brew.sh/Formula-Cookbook.html
#                http://www.rubydoc.info/github/Homebrew/brew/master/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class Samba4 < Formula
  desc "SMB/CIFS file, print, and login server for UNIX"
  homepage "https://www.samba.org/"
  url "https://download.samba.org/pub/samba/samba-4.7.3.tar.gz"
  sha256 "06e4152ca1cb803f005e92eb6baedb6cc874998b44ee37c2a7819e77a55bfd2c"

  conflicts_with "talloc", :because => "both install `include/talloc.h`"
  #conflicts_with "samba", :because => "both install samba"

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
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install" # if this fails, try separate make/make install steps

    Dir["#{lib}/private/*[0-9].[0-9]*"].each do |filelib|
      if not File.stat(filelib).symlink? then
        basef=File.basename(filelib)
        stripfilename=basef.gsub(/[0-9.]*.dylib/,'.dylib')
	stripfilename4=basef.gsub(/[0-9.]*.dylib/,'4.dylib')
        puts "#{lib}/private/#{basef} => #{lib}/private/#{stripfilename}"
        ln_sf "#{lib}/private/#{basef}", "#{lib}/private/#{stripfilename}"
	ln_sf "#{lib}/private/#{basef}", "#{lib}/private/#{stripfilename4}"
      end
    end
    #ln_sf "#{lib}/private/libtalloc.2.dylib", "#{lib}/private/libtalloc.dylib"
    #ln_sf "#{lib}/private/libtevent.0.dylib", "#{lib}/private/libtevent.dylib"
    #ln_sf "#{lib}/private/libtdb.1.dylib", "#{lib}/private/libtdb.dylib"
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
