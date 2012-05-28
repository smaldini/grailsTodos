grails.servlet.version = "2.5" // Change depending on target container compliance (2.5 or 3.0)
grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
grails.project.target.level = 1.6
grails.project.source.level = 1.6
//grails.project.war.file = "target/${appName}-${appVersion}.war"
grails.plugin.location.'si-events' = '../plugin-platform-project/grails-plugin-platform-incubator/events-si'
grails.plugin.location.'push-events' = '../plugin-platform-project/events-push'

grails.tomcat.nio = true

grails.project.dependency.resolution = {
    // inherit Grails' default dependencies
    inherits("global") {
        // specify dependency exclusions here; for example, uncomment this to disable ehcache:
        // excludes 'ehcache'
    }
    log "warn" // log level of Ivy resolver, either 'error', 'warn', 'info', 'debug' or 'verbose'
    checksums true // Whether to verify checksums on resolve

    repositories {
        inherits true // Whether to inherit repository definitions from plugins

        grailsPlugins()
        grailsHome()
        grailsCentral()

        mavenLocal()
        mavenCentral()

        // uncomment these (or add new ones) to enable remote dependency resolution from public Maven repositories
        //mavenRepo "https://oss.sonatype.org/content/repositories/snapshots"
        //mavenRepo "http://repository.codehaus.org"
        //mavenRepo "http://download.java.net/maven/2/"
        //mavenRepo "http://repository.jboss.com/maven2/"
    }
    dependencies {
        // specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.
        // runtime 'mysql:mysql-connector-java:5.1.18'
        runtime 'org.springframework.integration:spring-integration-amqp:2.1.1.RELEASE'

       /* def tomcatVersion = "7.0.27"
       build("org.apache.tomcat:tomcat-catalina-ant:$tomcatVersion") {
           transitive = false
       }
       build "org.apache.tomcat.embed:tomcat-embed-core:$tomcatVersion"
       build "org.apache.tomcat.embed:tomcat-embed-jasper:$tomcatVersion"
       build "org.apache.tomcat.embed:tomcat-embed-logging-log4j:$tomcatVersion"

       build "org.grails:grails-plugin-tomcat:${grailsVersion}"*/

       //compile 'org.atmosphere:atmosphere-runtime:0.9-SNAPSHOT'
    }

    plugins {
        runtime ":jquery:1.7.1"
        runtime ":resources:1.1.6"
        runtime ":coffeescript-resources:0.3.2"

        runtime ":cloud-foundry:1.2.2"
        runtime ":hibernate:$grailsVersion"
        //runtime ":redis:1.0.0.M8"
        runtime ":rabbitmq:1.0.0.RC1"

        // Uncomment these (or add new ones) to enable additional resources capabilities
        //runtime ":zipped-resources:1.0"
        //runtime ":cached-resources:1.0"
        //runtime ":yui-minify-resources:0.1.4"



        build ":tomcat:$grailsVersion"

        //runtime ":database-migration:1.0"
    }
}
