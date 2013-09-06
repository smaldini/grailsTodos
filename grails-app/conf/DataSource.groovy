import org.cloudfoundry.runtime.env.CloudEnvironment
import org.cloudfoundry.runtime.env.RdbmsServiceInfo

def cloudEnv = new CloudEnvironment()

dataSource {
	pooled = true
	driverClassName = "org.h2.Driver"
	username = "sa"
	password = ""
}
hibernate {
	cache.use_second_level_cache = true
	cache.use_query_cache = false
	cache.region.factory_class = 'net.sf.ehcache.hibernate.EhCacheRegionFactory'
}
// environment specific settings
environments {
	development {
		dataSource {
			dbCreate = "create-drop" // one of 'create', 'create-drop', 'update', 'validate', ''
			url = "jdbc:h2:mem:devDb;MVCC=TRUE"
		}
	}
	test {
		dataSource {
			dbCreate = "update"
			url = "jdbc:h2:mem:testDb;MVCC=TRUE"
		}
	}
	production {
		dataSource {
			dbCreate = 'update'
			driverClassName = 'com.mysql.jdbc.Driver'
			dialect = org.hibernate.dialect.MySQLInnoDBDialect

			if (cloudEnv.isCloudFoundry()) {
				def dbInfo = cloudEnv.getServiceInfo('dummy-mysql', RdbmsServiceInfo.class)
				url = dbInfo.url
				username = dbInfo.userName
				password = dbInfo.password
			} else {
				url = 'jdbc:mysql://localhost:5432/myapp'
				username = 'sa'
				password = ''
			}

			properties {
				maxActive = -1
				minEvictableIdleTimeMillis = 1800000
				timeBetweenEvictionRunsMillis = 1800000
				numTestsPerEvictionRun = 3
				testOnBorrow = true
				testWhileIdle = true
				testOnReturn = true
				validationQuery = "SELECT 1"
			}
		}
	}
}
