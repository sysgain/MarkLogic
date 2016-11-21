Feature: Provision a vnet-subnet

	Background:
    	Given I have opened the "/vnet-subnet/vnet-subnet.json" template

    
    Scenario: Validate the Template Against the Azure Validator
        Given I uploaded the template to Validator
        Then It should return a sucess payload

    Scenario Outline: Key is/not Present.
        Then  <key> <is> present in the <type> file

        Examples:
        | key                               				| is    | type      |
        #Template.json
        | $schema                           				| yes   | template  |
        | contentVersion                    				| yes   | template  |
        | parameters.location.defaultValue  				| yes   | template  |
        | testKey                           				| no    | template  |
        | resources.0.name                  				| yes   | template  | 
        | resources.0.properties.storageProfile.imageReference.sku 	| yes 	| template|
        #parameters.json
        | parameters.location.value         | yes   | params    |
        | parameters.vnetName.value         | yes   | params    |
        | testKey1                          | no    | params    |
        | testKey23                         | no    | params    |


    Scenario Outline: Key has/not a specific value.
      When <key> is the key on <type> file
      Then <value> <should> be its value

      Examples:
        | key                                | value                                                                                    | type      | should  |
        #Template.json
        | $schema                            | https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#          | template  | yes     |
        | contentVersion                     | 1.0.0.0                                                                                  | template  | yes     |
        | $schema                            | testvalue                                                                                | template  | no      |
        | contentVersion                     | 1.0.0.1                                                                                  | template  | no      |
        #parameters.json
        | parameters.vnetAddressPrefix.value | 10.0.0.0/16                                                                              | params    | yes     |
        | parameters.subnet1Prefix.value     | 10.0.1.0/24                                                                              | params    | yes     |  
        | parameters.vnetAddressPrefix.value | testValue                                                                                | params    | no      |
        | parameters.subnet1Prefix.value     | testUser                                                                                 | params    | no      | 

    Scenario Outline: Key contains a value.
        When <key> is the key on <type> file
        Then value <should> contain <value>

        Examples:
        | key                                   | value                                 | type          | should        |
        #template.json
        |  $schema                              | 2015-01-01/deploymentTemplate.json    | template      | yes           |
        |  $schema                              | test                                  | template      | no            |

        #parameters.json
        | parameters.vnetAddressPrefix.value    | 0/16                                  | params        | yes           |
        | parameters.vnetAddressPrefix.value    | 0/18                                  | params        | no            |
