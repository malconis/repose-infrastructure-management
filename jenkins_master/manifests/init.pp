##Installs jenkins to /var/lib/jenkins. Check /etc/init.d/jenkins and /etc/sysconfig/jenkins to see where it puts other things.
class jenkins_master {
    include common_utils
    include manual_java
    include manual_groovy
    include manual_maven
    include manual_gradle
    include git
    require iptables::clean

    $jenkins_home = '/var/lib/jenkins'
    $plugins_dir = "$jenkins_home/plugins"

    package {'expect':
        ensure      => 'installed',
    }

    yumrepo { "jenkins":
        baseurl     => "http://pkg.jenkins-ci.org/redhat",
        descr       => "The jenkins repository",
        enabled     => "1",
    }

    exec { "rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key":
        path        => "/usr/bin:/usr/sbin:/bin:/usr/local/bin",
        refreshonly => true,
        subscribe   => Yumrepo['jenkins'],
        require     => Yumrepo['jenkins'],
    }

    package { "jenkins":
        ensure      => '1.534-1.1',
        require     => Exec['rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key'],
    }

    package { "rpm-build":
        ensure => "4.4.2.3-34",
    }

    group {'jenkins':
        ensure => present,
    }

    user {'jenkins':
        ensure  => present,
        gid     => 'jenkins',
        home    => $jenkins_home,
        shell   => '/bin/bash',
        require => Package['jenkins'],
    }

    file { "$jenkins_home/.ssh":
        ensure  => directory,
        owner   => jenkins,
        group   => jenkins,
        mode    => '0700',
        require => Package['jenkins'],
    }

    file { ["$jenkins_home/.m2", "$jenkins_home/.gradle"]:
        ensure  => directory,
        owner   => jenkins,
        group   => jenkins,
        mode    => '0755',
        require => Package['jenkins'],
    }

    file { "$jenkins_home/hudson.tasks.Maven.xml":
        ensure  => present,
        source  => 'puppet:///modules/jenkins_master/maven-plugin-config',
        owner   => jenkins,
        group   => jenkins,
        mode    => '0644',
        require => Package['jenkins'],
    }

    service { 'jenkins':
        require     => [Package['jenkins'], Class['manual_java']],
        enable      => true,
        ensure      => running,
    }

    # Captain's log, star date 20131009: We've encountered a strange life form that seems to exist in two time zones...
    # This file says US/Central, but /etc/sysconfig/clock says UTC. We think there was some problem related to this discrepancy in the
    # past but can't remember what it is. If it comes up again, we should try managing that second file and making the time zones
    # agree.
    file { '/etc/localtime':
        ensure => present,
        source => '/usr/share/zoneinfo/US/Central',
    }

    ### Configure Networking

    iptables::allow { 'tcp/22':
        port     => '22',
        protocol => 'tcp',
    }

    iptables::allow { 'tcp/8080':
        port     => '8080',
        protocol => 'tcp',
    }

    ###### Install Plugins #######

    file { "$plugins_dir":
        ensure      => directory,
        owner       => 'jenkins',
        group       => 'jenkins',
        require     => Package['jenkins'],
    }

    define plugin ($url = $title, $file, $plugins_dir = $jenkins_master::plugins_dir) {
        common_utils::download { $url:
            file        => $file,
            target_dir  => $plugins_dir,
            require     => File[$plugins_dir],
            before      => Service['jenkins'],
            user        => 'jenkins',
        }
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/build-pipeline-plugin/1.3.3/build-pipeline-plugin.hpi':
        file    => 'build-pipeline-plugin.hpi',
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/dashboard-view/2.5/dashboard-view.hpi':
        file    => 'dashboard-view.hpi',
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/git/1.3.0/git.hpi':
        file    => 'git.hpi',
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/git-client/1.0.5/git-client.hpi':
        file    => 'git-client.hpi',
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/parameterized-trigger/2.17/parameterized-trigger.hpi':
        file    => 'parameterized-trigger.hpi',
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/multiple-scms/0.2/multiple-scms.hpi':
        file    => 'multiple-scms.hpi',
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/token-macro/1.6/token-macro.hpi':
        file    => 'token-macro.hpi',
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/groovy/1.13/groovy.hpi':
        file    => 'groovy.hpi',
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/veracode-scanner/1.1/veracode-scanner.hpi':
        file    => 'veracode-scanner.hpi',
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/github-api/1.42/github-api.hpi':
        file    => 'github-api.hpi',
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/github/1.6/github.hpi':
        file    => 'github.hpi',
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/ghprb/1.8/ghprb.hpi':
        file    => 'ghprb.hpi',
    }

    plugin {'http://updates.jenkins-ci.org/download/plugins/gradle/1.23/gradle.hpi':
        file    => 'gradle.hpi',
    }
}