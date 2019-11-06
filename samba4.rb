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


diff -ur samba-4.7.12/libcli/smbreadline/smbreadline.c samba-4.7.12-mod/libcli/smbreadline/smbreadline.c
--- samba-4.7.12/libcli/smbreadline/smbreadline.c	2017-07-04 12:05:25.000000000 +0200
+++ samba-4.7.12-mod/libcli/smbreadline/smbreadline.c	2019-11-06 06:49:47.000000000 +0100
@@ -47,20 +47,22 @@
 
 static bool smb_rl_done;
 
-#if HAVE_LIBREADLINE
 /*
+#if HAVE_LIBREADLINE
+
  * MacOS/X does not have rl_done in readline.h, but
  * readline.so has it
- */
 extern int rl_done;
 #endif
+*/
 
 void smb_readline_done(void)
 {
	smb_rl_done = true;
-#if HAVE_LIBREADLINE
+/*#if HAVE_LIBREADLINE
	rl_done = 1;
 #endif
+*/
 }
 
 /****************************************************************************
diff -ur samba-4.7.12/source4/torture/local/nss_tests.c samba-4.7.12-mod/source4/torture/local/nss_tests.c
--- samba-4.7.12/source4/torture/local/nss_tests.c	2017-07-04 12:05:26.000000000 +0200
+++ samba-4.7.12-mod/source4/torture/local/nss_tests.c	2019-11-06 06:48:50.000000000 +0100
@@ -345,7 +345,7 @@
 
	torture_comment(tctx, "Testing setpwent\n");
	setpwent();
-
+#ifdef HAVE_GETPWENT_R /* getpwent_r not supported on macOS */
	while (1) {
		torture_comment(tctx, "Testing getpwent_r\n");
 
@@ -368,6 +368,7 @@
			num_pwd++;
		}
	}
+	#endif /* getpwent_r not supported on macOS */
 
	torture_comment(tctx, "Testing endpwent\n");
	endpwent();
@@ -544,6 +545,7 @@
	torture_comment(tctx, "Testing setgrent\n");
	setgrent();
 
+	#ifdef HAVE_GETGRENT_R /* getgrent_r not supported on macOS */
	while (1) {
		torture_comment(tctx, "Testing getgrent_r\n");
 
@@ -566,6 +568,7 @@
			num_grp++;
		}
	}
+	#endif /* getgrent_r not supported on macOS */
 
	torture_comment(tctx, "Testing endgrent\n");
	endgrent();

