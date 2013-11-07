class manual_java ($version = '1.7.0_06', $stripped_down = false) {

  $file_version = $version ? {
    /(.*)_0*(.*)/ => "$1.$2",
  }

  common_utils::download_and_extract {"'http://dev-hudson1.sat.intensive.int:8071/nexus/service/local/artifact/maven/redirect?r=thirdparty&g=com.oracle&a=jdk&v=$file_version&e=tar.gz&c=linux-x64'":
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
