grails.servlet.version = "3.0" // Change depending on target container compliance (2.5 or 3.0)
grails.project.class.dir = "target/classes"
grails.project.test.class.dir = "target/test-classes"
grails.project.test.reports.dir = "target/test-reports"
grails.project.target.level = 1.7
grails.project.source.level = 1.7
//grails.plugin.location.'platformCore' = '../platform-core'
//grails.plugin.location.'eventsSi' = '../plugin-platform-project/grails-plugin-platform-incubator/events-si'
//grails.plugin.location.'eventsPush' = '../grails-events-push'
//grails.project.war.file = "target/${appName}-${appVersion}.war"

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
		mavenLocal()

		mavenLocal()
		grailsCentral()
		grailsPlugins()
		grailsHome()

		mavenCentral()

		// uncomment these (or add new ones) to enable remote dependency resolution from public Maven repositories
		//mavenRepo "https://oss.sonatype.org/content/repositories/snapshots"
		//mavenRepo "http://repository.codehaus.org"
		//mavenRepo "http://download.java.net/maven/2/"
		//mavenRepo "http://repository.jboss.com/maven2/"
		mavenRepo "https://oss.sonatype.org/content/repositories/snapshots"
		mavenRepo 'https://repo.springsource.org/libs-snapshot/'
		mavenRepo "http://repo.grails.org/grails/libs-snapshots-local/"
	}
	dependencies {
		// specify dependencies here under either 'build', 'compile', 'runtime', 'test' or 'provided' scopes eg.
		runtime 'mysql:mysql-connector-java:5.1.24'
		//runtime 'org.springframework.integration:spring-integration-dsl-groovy-amqp:1.0.0.BUILD-SNAPSHOT'
		compile "org.cloudfoundry:cloudfoundry-runtime:0.8.4"
		compile 'org.grails.plugins:events:1.0.0.BUILD-SNAPSHOT'
	}

	plugins {
		runtime ":jquery:1.10.2"
		compile ":resources:1.2"
		runtime(":coffeescript-resources:0.3.2") {
			exclude 'resources'
		}

		runtime ":hibernate:3.6.10.M6" // or ":hibernate4:4.1.11.M2"

		//runtime ":rabbitmq:1.0.0"

		//runtime (":events-si:1.0.M5")
		//runtime (":vertx:1.0-SNAPSHOT")
		runtime ":events-push:1.0.0.BUILD-SNAPSHOT"

		build ":tomcat:7.0.42"
	}
}
