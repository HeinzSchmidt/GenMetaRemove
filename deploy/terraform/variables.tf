variable "region" {
    type = string
    default = "eu-west-2"
}

variable "inbox_user" {
    type = string
    default = "User_A"
    description = "User with permissions to read/write to s3-photo-inbox bucket"
}

variable "outbox_user" {
    type = string
    default = "User_B"
    description = "User with permissions to read from s3-photo-inbox bucket"
}