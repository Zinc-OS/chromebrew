require 'package'

class Gtk3 < Package
  description 'GTK+ is a multi-platform toolkit for creating graphical user interfaces.'
  homepage 'https://developer.gnome.org/gtk3/3.0/'
  @_ver = '3.24.27'
  @_ver_prelastdot = @_ver.rpartition('.')[0]
  version @_ver
  compatibility 'all'
  source_url "https://gitlab.gnome.org/GNOME/gtk/-/archive/#{@_ver}/gtk-#{@_ver}.tar.bz2"
  # source_url "https://download.gnome.org/sources/gtk/#{@_ver_prelastdot}/gtk-#{@_ver}.tar.xz"
  source_sha256 'dbc3b14ae0d8e44bc8caeac91d62b4d2403a881d837cb4e9bcfb8d138712c3a3'

  binary_url({
    aarch64: 'https://dl.bintray.com/chromebrew/chromebrew/gtk3-3.24.27-chromeos-armv7l.tar.xz',
     armv7l: 'https://dl.bintray.com/chromebrew/chromebrew/gtk3-3.24.27-chromeos-armv7l.tar.xz',
       i686: 'https://dl.bintray.com/chromebrew/chromebrew/gtk3-3.24.27-chromeos-i686.tar.xz',
     x86_64: 'https://dl.bintray.com/chromebrew/chromebrew/gtk3-3.24.27-chromeos-x86_64.tar.xz'
  })
  binary_sha256({
    aarch64: '29a4642e0887f09c4d9950fd9ca7ac7246c455ae91aeed25268658857c66a39e',
     armv7l: '29a4642e0887f09c4d9950fd9ca7ac7246c455ae91aeed25268658857c66a39e',
       i686: '0022f857e4697bad885232d246de0e12403ec6a99e63ef43f292882c0becc467',
     x86_64: '59e5324c659a0c9803e906717eebd82c6a3818539d1336beae603fd591ca0e9c'
  })

  depends_on 'adwaita_icon_theme'
  depends_on 'atk'
  depends_on 'at_spi2_atk'
  depends_on 'cantarell_fonts'
  depends_on 'cups'
  depends_on 'gdk_pixbuf'
  depends_on 'gnome_icon_theme'
  depends_on 'gobject_introspection'
  depends_on 'graphene'
  depends_on 'graphite'
  depends_on 'hicolor_icon_theme'
  depends_on 'iso_codes'
  depends_on 'json_glib'
  depends_on 'libdeflate'
  depends_on 'libepoxy'
  depends_on 'libxkbcommon'
  depends_on 'shared_mime_info'
  depends_on 'six' => :build
  depends_on 'xdg_base'

  def self.build
    system "meson #{CREW_MESON_LTO_OPTIONS} \
      -Dbroadway_backend=true \
      -Ddemos=false \
      -Dexamples=false \
      -Dgtk_doc=false \
      builddir"
    system 'meson configure builddir'
    system 'ninja -C builddir'
    @gtk3settings = <<~GTK3_CONFIG_HEREDOC
      [Settings]
      gtk-icon-theme-name = Adwaita
      gtk-fallback-icon-theme = gnome
      gtk-theme-name = Adwaita
      gtk-font-name = Cantarell 11
      gtk-application-prefer-dark-theme = false
    GTK3_CONFIG_HEREDOC
  end

  def self.install
    system "DESTDIR=#{CREW_DEST_DIR} ninja -C builddir install"
    system "sed -i 's,null,,g'  #{CREW_DEST_LIB_PREFIX}/pkgconfig/gtk*.pc"
    FileUtils.mkdir_p "#{CREW_DEST_PREFIX}/etc/gtk-3.0"
    File.write("#{CREW_DEST_PREFIX}/etc/gtk-3.0/settings.ini", @gtk3settings)
  end

  def self.postinstall
    # generate schemas
    system "glib-compile-schemas #{CREW_PREFIX}/share/glib-2.0/schemas"
    # update mime database
    system "update-mime-database #{CREW_PREFIX}/share/mime"
  end
end
