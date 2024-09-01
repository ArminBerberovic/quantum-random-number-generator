variable "location" {
  type = string
  default = "eastus"
}

variable "subscription_id" {
    type = string
}

variable quantum_workspace_name {
  type = string
}

variable target {
  type = string
}

variable retriever_func_name {
    type = string
}

variable submitter_func_name {
    type = string
}
