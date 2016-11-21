Feature: Provision a vnet-subnet

	Background:
    	Given I have opened the "/sample-component/chef-server.json" template

     Scenario: Validate the Template Against the Azure Validator
        Given I uploaded the template to Validator
        Then It should return a sucess payload

    Scenario Outline: Key is/not Present.
        Then  <key> <is> present in the <type> file

        Examples:
        | key                               | is    | type      |
        #Template.json
        | $schema                           | yes   | template  |
        | contentVersion                    | yes   | template  |
        | parameters.location.defaultValue  | yes   | template  |
        #parameters.json
        | parameters.location.value         | yes   | params    |

    Scenario Outline: Key has/not a specific value.
      When <key> is the key on <type> file
      Then <value> <should> be its value

      Examples:
        | key                                | value                                                                                    | type      | should  |
        #Template.json
        | $schema                            | https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#          | template  | yes     |
        | contentVersion                     | 1.0.0.0                                                                                  | template  | yes     |
        | $schema                            | testvalue                                                                                | template  | no      |
        | variables.imagePublisher           | chef-software                                                                            | template  | yes      |

        #parameters.json
        | parameters.adminUsername.value     | sysgain                                                                                  | params    | yes     |
        
