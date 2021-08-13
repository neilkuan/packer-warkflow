locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }


# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioners and post-processors on a
# source.

variable project_id {
  type    = string
}


source "googlecompute" "basic-example" {
  project_id = var.project_id
  source_image = "debian-9-stretch-v20200805"
  ssh_username = "packer"
  zone = "us-central1-a"
  tags = ["default-allow-ssh"]
}


# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["sources.googlecompute.basic-example"]
  
  provisioner "file" {
    source      = "../tf-packer.pub"
    destination = "/tmp/tf-packer.pub"
  }
  provisioner "shell" {
    script = "../scripts/setup.sh"
  }
}
