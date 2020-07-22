/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

module "sg-unused" {

  #source = "github.com/ministryofjustice/cloud-platform-terraform-report-unused-sg?ref=v1.0"
  source = "../"
  slack_hook_url = "<SLACK_TOKEN>"
  #schedule      = "<SCHEDULE>"
  # To execute a test job, uncomment the below var and leave as false. This will execute a 'job' instead of a 'cron job'.
   cronjob       = false
}