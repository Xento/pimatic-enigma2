module.exports = {
  title: "enigma config options"
  type: "object"
  required: ["ip"]
  properties: 
    user:
      description:"Username for webinterface"
      type: "string"
      required: yes
    password:
      description:"Password for webinterface"
      default: ""
      required: yes
    port:
      description:"Port of the webinterface"
      type: "string"
      default: "80"
    ip:
      description:"IP-Address of your receiver"
      type: "string"
      default: ""
    timeout: #might be overwritten by predicate
      description:"Timeout after that the message disappears"
      type: "integer"
      default: 30
    messagetype: #might be overwritten by predicate
      description:"How is the message shown on the TV"
      type: "string"
      default: "info"
}