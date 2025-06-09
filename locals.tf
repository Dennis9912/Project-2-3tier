locals {
  project_tags = {
    contact      = "amankwah9912@gmail.com"
    application  = "DFX"
    project      = "Atech"
    environment  = "${terraform.workspace}" # refers to your current workspace (dev, prod, etc)
    creationTime = timestamp()
  }
}
