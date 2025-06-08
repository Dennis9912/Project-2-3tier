locals {
  project_tags = {
    contact      = "amankwah9912@gmail.com"
    application  = "Fxapp"
    project      = "DenTech"
    environment  = "${terraform.workspace}" # refers to your current workspace (dev, prod, etc)
    creationTime = timestamp()
  }
}
