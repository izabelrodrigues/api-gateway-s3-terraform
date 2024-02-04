variable "supported_binary_media_types" {
  description = "Supported file types"
  type        = list(string)

  default = [
    "application/octet-stream",
    "image/jpeg",
    "image/gif",
    "image/png",
    "application/vnd.ms-excel",                                             #.xls, .xlt, .xla
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",    #.xlsx
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template", #.xltx
    "application/vnd.ms-excel.sheet.macroEnabled.12",                       #.xlsm
    "application/vnd.ms-excel.template.macroEnabled.12",                    #.xltm
    "application/vnd.ms-excel.addin.macroEnabled.12",                       #.xlam     
    "application/vnd.ms-excel.sheet.binary.macroEnabled.12",                #.xlsb

  ]
}

variable "region" {
  default = "us-east-1"
}
