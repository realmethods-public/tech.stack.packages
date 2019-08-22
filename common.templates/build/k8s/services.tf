#if( ${containerObject} )
#set( $appName = "Container-${containerObject.getName()}" )
#else
#set( $appName = $aib.getApplicationNameFormatted() )
#end
resource "kubernetes_service" "app-master" {
  metadata {
    name = "app-master"

    labels {
      app  = "${appName}demo"
    }
  }

  spec {
    selector {
      app  = "${appName}"
    }
################################################################
## expose the application port
################################################################
    port {
      name        = "app-port"
      port        = 8080
      target_port = 8080
    }

################################################################
## expose the Mongoose port so the remote client 
## can invoke actions on it
################################################################
    port {
      name        = "mongoose-port"
      port        = 4000
      target_port = 4000
    }
    
################################################################    
## expose the MongoDB port for better remote client 
## testing using tools like Robo3T
################################################################
    port {
      name        = "mongo-port"
      port        = 27017
      target_port = 27017
    }

################################################################
## Load balancing will automatically expose the prots publically
################################################################
    type = "LoadBalancer"
  }
  
}
