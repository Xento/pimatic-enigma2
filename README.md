pimatic-enigma2
=======================

A plugin for controlling a linux sat receiver with enigma2 or openwebif installed.


Configuration
-------------
You can load the backend by editing your `config.json` to include:

    {
      "plugin": "enigma2",
      "ip": "192.168.x.x"
    }

in the `plugins` section. For all configuration options see 
[enigma2-config-schema](enigma2-config-schema.coffee)

Currently you can send notifications to your receiver

Example:
--------

    if it is 08:00 tv-message message:"Good morning Dave!" [messagetype:"info"] [timeout: 30]


I invite everybody to contribute to this plugin.
Here you can find the api of the webinterface http://dream.reichholf.net/e2web/.
