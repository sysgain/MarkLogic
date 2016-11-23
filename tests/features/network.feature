Feature: Provision a mainTemplate

	Background:
    	Given I have opened the "/mainTemplate.json" template

    
    Scenario: Validate the Template Against the Azure Validator
        Given I uploaded the template to Validator
        Then It should return a sucess payload

    Scenario Outline: Key is/not Present.
        Then  <key> <is> present in the <type> file

        Examples:
        | key                                                       | is    | type      |
        #Template.json
        | $schema                           	                    | yes   | template  |
        | contentVersion                    	                    | yes   | template  |
        | parameters.loadBalancerType                               | yes   | template  |
        | parameters.loadBalancerpublicIPdnsPrefix                  | yes   | template  |
        | parameters.internalLoadBalancerPrivateIP                  | yes   | template  |
        | parameters.nodepublicIPdnsPrefix                          | yes   | template  |
        | variables.apiVersions.networkApiVersion                   | yes   | template  | 
        | variables.networkSettings                                 | yes   | template  | 
        | variables.networkSettings.nodeNetworkSettings             | yes   | template  | 
        | variables.networkSettings.loadBalancerNetworkSettings     | yes   | template  |
        | variables.networkSettings.nodeNetworkSettings.location             | yes   | template  | 
        | variables.networkSettings.loadBalancerNetworkSettings.location     | yes   | template  |
       
        | resources.0.properties.parameters.templateUrls            | yes   | template  |
        | resources.0.properties.parameters.networkSettings         | yes   | template  |
        | resources.1.properties.parameters.apiVersions             | yes   | template  |
        | resources.1.properties.parameters.templateUrls            | yes   | template  |
        | resources.1.properties.parameters.networkSettings         | yes   | template  |
        
        

    Scenario Outline: Key has/not a specific value.
      When <key> is the key on <type> file
      Then <value> <should> be its value

      Examples:
        | key                                | value                                                                              | type      | should  |
        #Template.json
        | $schema                            | https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#    | template  | yes     |
        | contentVersion                     | 1.0.0.0                                                                            | template  | yes     |
        | variables.networkSettings.count    | [parameters('clusterNodeCount')]                                                   | template  | yes     |
        | parameters.loadBalancerType.allowedValues.0 | external    | template  | yes     |
        | parameters.loadBalancerType.allowedValues.1 | internal    | template  | yes     |     
        

        
        
        
       

    Scenario Outline: Key contains a value.
        When <key> is the key on <type> file
        Then value <should> contain <value>

        Examples:
        | key                      | value                                 | type          | should    |
        #template.json
        |  $schema                 | 2015-01-01/deploymentTemplate.json    | template      | yes       |

      