variable "cluster_name" {
  default = "demo"
}

variable "knative_version" {
  description = "The version of knative to install"
  type        = string
  default     = "v1.15.3"
}

variable "knative_istio_int_version" {
  description = "The version of knative istio intergation to install"
  type        = string
  default     = "v1.15.1"
}

variable "knative_cosign_image_check" {
  description = "The version of knative verify by cosign"
  type        = string
  default     = "v1.15.2"
}