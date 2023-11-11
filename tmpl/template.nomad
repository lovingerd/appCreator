job {{job_name}} {
  datacenters = [{{ env.meta.datacenters | default('"cdev"') }}]
  spread {
    attribute = "${node.datacenter}"
  }
  region = "{{ env.name }}"
  priority = 50
  group "lmc-{{job_name}}" {
    # VAR instances
    count = {{instance_count}}
    # max 2 instances on a single node
    constraint {
      operator = "distinct_property"
      attribute = "${attr.unique.hostname}"
      value     = "2"
    }
    vault {
      policies = [
        # access global data, e.g. cacerts.jks, common RSA keys
        "global-r",
        "deployment_nrw_recruit"
      ]
      env = true
      change_mode   = "noop"
      change_signal = ""
    }
    network {
      # dynamic ports
      port "http" { to = 8080 }
      port "jmx" {}
      port "jmxrmi" {}
{% if env.type != "prod" %}
      port "debug" {}
{% endif %}
    }
    task "lmc-{{job_name}}-{{docker.version}}" {
      driver = "docker"
      kill_timeout = "{{ kill_timeout or '5' }}s"
      shutdown_delay = "{{ shutdown_delay or '0' }}s"
      config {
        image = "{{docker.image}}:{{docker.version}}"
        hostname = "{{app_name|lower}}-${NOMAD_ALLOC_INDEX}"
        ports = ["http", "jmx", "jmxrmi"{% if env.type != "prod" %}, "debug"{% endif %}]
      }
      {% if has_db_credentails %}
      # user name for DB rw access
      template {
        data = <<EOF
        [[ with secret "postgresql-database/creds/pgteamio_{{app_name|lower}}_rw" ]]
        watched.datasource.username=[[ .Data.username ]]
        watched.datasource.password=[[ .Data.password ]]
        [[ end ]]
        EOF
        left_delimiter = "[["
        right_delimiter = "]]"
        # Could not use ${NOMAD_SECRETS_DIR}: https://github.com/hashicorp/nomad/issues/4163
        destination = "secrets/watched.properties"
        env = false
        #do nothing
        change_mode = "noop"
      }
      {% endif %}
      resources {
        cpu = {{ ((cpu_cores or 2) * 1024) - 1023 }}
        memory = {{ xmx_ram_MB + metaspace_ram_MB + (cpu_cores or 2) * 300 }}
      }
      logs {
        max_files     = 5
        max_file_size = 1
      }
      constraint {
        attribute = "${node.class}"
        operator = "="
        # runtime
        value = "{{package_runtime}}"
      }
      template {
        #read artemis nodes from consul and store them in a file
        #the file is being read at application start and nodes are used for configuration
        data = "ARTEMIS_HOSTS_PORTS=[[range $index, $service := service \"activemqartemis-amqartall-nodes|any\"]][[if ne $index 0]],[[end]]tcp://[[.Node]]:[[.Port]][[end]]"
        env = true
        left_delimiter = "[["
        right_delimiter = "]]"
        destination = "/local/artemisHostsPorts"
        perms = "644"
        change_mode = "noop"
      }
      env {
        JAVA_OPTS = "-XX:MaxMetaspaceSize={{ metaspace_ram_MB }}m -XX:+UseG1GC -XX:ThreadStackSize=320 -XX:MaxGCPauseMillis=200 -Dcom.sun.management.jmxremote.port=${NOMAD_HOST_PORT_jmx} -Dcom.sun.management.jmxremote.rmi.port=${NOMAD_HOST_PORT_jmxrmi} -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Djava.rmi.server.hostname=${NOMAD_IP_jmx}"
        JAVA_OPTS_XMX = "-Xmx{{xmx_ram_MB}}m"
        JAVA_OPTS_XMS = "-Xms{{xms_ram_MB}}m"
      }
      service {
        name = "{{job_name}}"
        tags = [
          "Owner: Teamio"
        ]
        port = "http"
        check {
          name = "alive"
          type = "tcp"
          interval = "10s"
          timeout = "2s"
          port = "http"
        }
        check {
          name = "HEAD /actuator/health"
          type = "http"
          port = "http"
          method = "HEAD"
          path = "/actuator/health"
          # same interval and timeout as in Dockerfile
          interval = "30s"
          timeout = "10s"
        }
      }
      service {
        name = "{{job_name}}--jmx"
        tags = [
          "Owner: Teamio"
        ]
        port = "jmx"
        check {
          name = "alive"
          type = "tcp"
          interval = "10s"
          timeout = "2s"
          port = "jmx"
        }
      }
{% if env.type != "prod" %}
      service {
        name = "{{job_name}}--debug"
        tags = [
          "Owner: Teamio"
        ]
        port = "debug"
      }
{% endif %}
      service {
        name = "{{job_name}}--prometheus"
        tags = [
          "prometheus_metrics",
          "/actuator/prometheus"
        ]
        port = "http"
      }
    }
    ephemeral_disk {
      migrate = false
      size = "10"
      sticky = false
    }
  }
  update {
    auto_promote = {{ 'true' if canary == 1 else 'false' }}
    auto_revert = false
    canary = {{canary}}
    healthy_deadline = "3m"
    max_parallel = 1
    health_check = "checks"
    min_healthy_time = "10s"
  }
}