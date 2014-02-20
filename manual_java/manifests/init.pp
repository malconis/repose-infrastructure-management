class manual_java ($version = '1.7.51', $stripped_down = false) {

  $file_version = $version ? {
   /jdk-(.*)-linux.*/ => "$1",
  }

  common_utils::download_and_extract {"'http://maven.research.rackspacecloud.com/content/repositories/third-party/com/oracle/jdk/$file_version/jdk-$file_version-x64.tar.gz'":
    download_dir         => '/opt',
    archive_name         => "jdk-$file_version-linux-x64.tar.gz",
    exploded_archive_dir => "jdk$version",
  }

  file {'/opt/java':
    ensure => link,
    target => "/opt/jdk$version",
  }

  define add-to-path {
    file { "/usr/bin/${title}":
      ensure => link,
      target => "/opt/java/bin/${title}",
    }
  }

  add-to-path {['java', 'javac', 'javap', 'jmap', 'jstack', 'jar', 'jps', 'keytool', 'jstat']:}
}
