#if( ${containerObject} )
#set( $appName = "Container-${containerObject.getName()}" )
#else
#set( $appName = $aib.getApplicationNameFormatted() )
#end
resource "kubernetes_replication_controller" "app-master" {
  metadata {
    name = "app-master"

    labels {
      app  = "${appName}"
    }
  }

  spec {
    replicas = 1

    selector = {
      app  = "${appName}"
    }

################################################################
## MongoDB container
################################################################
    template {
      container {
        image = "mongo"
        name  = "mongo"

        port {
          container_port = 27017
        }

        resources {
          requests {
            cpu    = "100m"
            memory = "100Mi"
          }
        }
      }

################################################################
## ${appName} container
################################################################
#set( $dockerOrgName = ${aib.getParam("terraform.docker-org-name")} )
#set( $dockerRepo = ${aib.getParam("terraform.docker-repo")} )
#set( $dockerTag = ${aib.getParam("terraform.docker-tag")} )      
      container {
        image = "${dockerOrgName}/${dockerRepo}:${dockerTag}"
        name  = "app-container"
        
################################################################        
## need to make the Mongoose host available to the app Docker image
################################################################
        env {
          name  = "MONGOOSE_HOST_NAME"
          value = "${esc.dollar}{kubernetes_service.app-master.load_balancer_ingress.0.ip}"
                 
        }
        
################################################################
## expose the application ports
################################################################        
        port {
          container_port = 8080
        }

################################################################
## expose the mongoose ports
################################################################                        
        port {
          container_port = 4000
        }

        resources {
          requests {
            cpu    = "100m"
            memory = "100Mi"
          }
        }
      }
    }
  }
}

