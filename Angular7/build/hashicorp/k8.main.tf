#if( ${containerObject} )
#set( $appName = "Container-${containerObject.getName()}" )
#else
#set( $appName = $aib.getApplicationNameFormatted() )
#end
#set( $dockerOrgName = ${aib.getParam("terraform.docker-org-name")} )
#set( $dockerRepo = ${aib.getParam("terraform.docker-repo")} )
#set( $dockerTag = ${aib.getParam("terraform.docker-tag")} )

provider "kubernetes" {
  host = "$aib.getParam( "kubernetes.host" )"
  username = "${esc.dollar}{var.kubernetes-username}"
  password = "${esc.dollar}{var.kubernetes-password}"
}

resource "kubernetes_pod" "mongoPod" {
  metadata {
    name = "terraform-mongo-pod"
    labels = {
      app = "mongo"
    }
  }

  spec {
    container {
      image = "mongo"
      name  = "terraform-mongo-container"
    }
  }
}

resource "kubernetes_pod" "appPod" {
  metadata {
    name = "terraform-${appName}-pod"
    labels = {
      app = "${appName}"
    }
  }

  spec {
    container {
      image = "${dockerOrgName}/${dockerRepo}:${dockerTag}"
      name  = "terraform-${appName}-container"
      env {
        MONGOOSE_HOST_NAME = "${esc.dollar}{kubernetes_service.mongoPod.metadata.self_link}"
      }
    }
  }
  
}

resource "kubernetes_service" "mongoService" {
  metadata {
    name = "terraform-mongo-service"
  }
  spec {
    selector = {
      app = "${esc.dollar}{kubernetes_pod.mongoPod.metadata.labels.app}"
    }
#if ( $aib.getParam( "kubernetes.useSessionAffinity" ) == "true" )    
    session_affinity = "ClientIP"
#else
	session_affinity = "None"
#end ##if ( $aib.getParam( "kubernetes.useSessionAffinity" ) == "true" )
    port {
      port        = 8080
      target_port = 80
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "appService" {
  metadata {
    name = "terraform-${appName}-service"
  }
  spec {
    selector = {
      app = "${esc.dollar}{kubernetes_pod.appPod.metadata.labels.app}"
    }
#if ( $aib.getParam( "kubernetes.useSessionAffinity" ) == "true" )    
    session_affinity = "ClientIP"
#else
	session_affinity = "None"
#end ##if ( $aib.getParam( "kubernetes.useSessionAffinity" ) == "true" )
    port {
      port        = 8080
      target_port = 80
    }

    type = "$aib.getParam( "kubernetes.serviceType" )"
  }
}

