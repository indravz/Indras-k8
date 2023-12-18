module "kubernetes_master" {
  source = "./k8-cluster"

  #####Replace with your key######
  public_key             = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDTMW0UlgObFvOMx793o3mliM8ePOpla0DuTYzD5Guh2CLRlsaRgIjzEUUaekes2DxU50+qi35QBEgu8km2At2DX4CkSGBZTO2t4GQ0FK1TkkZBLoE3XQvmwSl847buMQ4vBqkf6owJlZ/DMJ8z/tIefpR5uFuTTMGV2vtDYZfMhy6nJuO04OHLbroaTHGwgLr+K7A/xmVAOiiOU/QxJabCcrQT2NRks9uIVgF5XrOLFh9p5WfbROHC9YY5hrr6mrx/Hxg7Z8X7KZcNDPjm9M8bYnor4iw+X+dD+g+VFC7H6VEfo6Og3SgHCJkacba8X7ovhYoqBO1arLdBKVYOvIrvcomBEGfX2MjgaED+eoLHBpg2i8lSviD3iF4J9mcKfAF3hofigSbPKmdBG24HS7NPNQPJW2swUTJCG/0VOJv1ko+EU26ZDEv8smp/19a+GRTAw0f/K0qmQjnQxK2+Ptm56GhZ/Qk53dl3OA5VzNl/WzvCNXmY8adb21xkW+53GNM= reddyin@Indras-Air.attlocal.net"
  security_group_cidr    = "71.159.246.98/32" # Replace with your ip
}