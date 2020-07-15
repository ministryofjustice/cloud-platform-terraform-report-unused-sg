
module "sg_user_cp" {
  source      = "./sg-aws-user"
  aws_profile = "moj-cp"
}

resource "kubernetes_secret" "sg_aws_credentials" {
  depends_on = [helm_release.sg_unused]

  metadata {
    name      = "aws-creds"
    namespace = kubernetes_namespace.sg_unused.id
  }

  data = {
    access-key-id     = module.sg_user_cp.id
    secret-access-key = module.sg_user_cp.secret
  }
}

resource "kubernetes_namespace" "sg_unused" {
  metadata {
    name = "sg-unused"

    labels = {
      "cloud-platform.justice.gov.uk/environment-name" = "production"
      "cloud-platform.justice.gov.uk/is-production"    = "true"
    }

    annotations = {
      "cloud-platform.justice.gov.uk/application"   = "unused-sg"
      "cloud-platform.justice.gov.uk/business-unit" = "cloud-platform"
      "cloud-platform.justice.gov.uk/owner"         = "Cloud Platform: platforms@digital.justice.gov.uk"
      "cloud-platform.justice.gov.uk/source-code"   = "https://github.com/ministryofjustice/cloud-platform-concourse"
    }
  }
}

resource "kubernetes_limit_range" "sg_unused" {
  metadata {
    name      = "limitrange"
    namespace = kubernetes_namespace.sg_unused.id
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "2"
        memory = "4000Mi"
      }
      default_request = {
        cpu    = "100m"
        memory = "100Mi"
      }
    }
  }
}

resource "kubernetes_secret" "sg_unused_slack_hook" {

  metadata {
    name      = "slack-hook-url"
    namespace = kubernetes_namespace.sg_unused.id
  }

  data = {
    value = var.slack_hook_url
  }
}

data "helm_repository" "sg_unused" {
  depends_on = [module.sg_user_cp.id]
  name = "sg-unused"
  url  = "https://ministryofjustice.github.io/cloud-platform-helm-charts"
}

resource "helm_release" "sg_unused" {

  depends_on = [module.sg_user_cp.id]
  name          = "sg_unused"
  namespace     = kubernetes_namespace.sg_unused.id
  #repository    = data.helm_repository.sg_snapshot_limit.metadata[0].name
  #chart         = "sg_unused"
  chart         = "/Users/imranawan/projects/cloud-platform-helm-charts/report-unused-sg/"
  version       = local.report-unused-sg


  values = [templatefile("${path.module}/templates/values.yaml", {
    cronjobEnabled          = var.cronjob
    cronjobSchedule         = var.schedule
  })]
}

##########
# Locals #
##########

locals {
  report-unused-sg = "0.1.0"
}

