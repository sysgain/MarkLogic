Feature: Provision a mainTemplate

	Background:
    	Given I have opened the "/mainTemplate.json" template

    
    Scenario: Validate the Template Against the Azure Validator
        Given I uploaded the template to Validator
        Then It should return a sucess payload

    Scenario Outline: Key is/not Present.
        Then  <key> <is> present in the <type> file

        Examples:
        | key                                   | is    | type      |
        #Template.json
        | $schema                           	| yes   | template  |
        | contentVersion                    	| yes   | template  |
        | parameters.clusterPrefix              | yes   | template  | 
        | parameters.clusterNodeCount           | yes   | template  |
        | parameters.baseUrl                    | yes   | template  |
        | parameters.location                   | yes   | template  |
        | variables.nodeVmSize                  | yes   | template  |
        | variables.cluster-size-1.vmSize       | yes   | template  |
        | variables.cluster-size-3.vmSize       | yes   | template  |
        | variables.cluster-size-4.vmSize       | yes   | template  |
        | variables.cluster-size-5.vmSize       | yes   | template  |
        | variables.cluster-size-6.vmSize       | yes   | template  |
        | variables.cluster-size-7.vmSize       | yes   | template  |
        | variables.cluster-size-8.vmSize       | yes   | template  |
        | variables.cluster-size-9.vmSize       | yes   | template  |
        | variables.cluster-size-10.vmSize      | yes   | template  |
        | variables.apiVersions                 | yes   | template  |
        | variables.apiVersions.deploymentApiVersion    | yes   | template  |
        | variables.apiVersions.networkApiVersion       | yes   | template  | 
        | variables.apiVersions.storageApiVersion       | yes   | template  | 
        | variables.apiVersions.computeApiVersion       | yes   | template  |
        | variables.networkSettings             | yes   | template  | 
        | variables.networkSettings.nodeNetworkSettings             | yes   | template  | 
        | variables.networkSettings.loadBalancerNetworkSettings     | yes   | template  |
        | variables.storageSettings             | yes   | template  | 
        | variables.storageSettings.osDiskStorage       | yes   | template  | 
        | variables.storageSettings.dataDiskStorage     | yes   | template  |
        | variables.virtualMachineSettings      | yes   | template  |
        | variables.virtualMachineSettings.dataDiskExtension          | yes   | template  |
        | variables.virtualMachineSettings.firstNodeConfigExtension   | yes   | template  |
        | variables.virtualMachineSettings.additionalNodesConfigExtension     | yes   | template  |
        | variables.virtualMachineSettings.createDataBaseExtension    | yes   | template  |
        | variables.virtualMachineSettings.createForestExtension      | yes   | template  |
        | variables.templateUrls                | yes   | template  |
        | resources.0.properties.parameters.templateUrls           | yes   | template  |
        | resources.0.properties.parameters.networkSettings        | yes   | template  |
        | resources.0.properties.parameters.storageAccountSettings | yes   | template  |
        | resources.1.properties.parameters.apiVersions            | yes   | template  |
        | resources.1.properties.parameters.templateUrls           | yes   | template  |
        | resources.1.properties.parameters.networkSettings        | yes   | template  |
        | resources.2.properties.parameters.apiVersions            | yes   | template  |
        | resources.2.properties.parameters.templateUrls           | yes   | template  |
        | resources.2.properties.parameters.virtualMachineSettings | yes   | template  |
        

    Scenario Outline: Key has/not a specific value.
      When <key> is the key on <type> file
      Then <value> <should> be its value

      Examples:
        | key                                | value                                                                              | type      | should  |
        #Template.json
        | $schema                            | https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#    | template  | yes     |
        | contentVersion                     | 1.0.0.0                                                                            | template  | yes     |
        | variables.cluster-size-1.nodes     | singlenode        | template  | yes   |
        | variables.cluster-size-3.nodes     | cluster           | template  | yes   |
        | variables.cluster-size-4.nodes     | cluster           | template  | yes   |
        | variables.cluster-size-5.nodes     | cluster           | template  | yes   |
        | variables.cluster-size-6.nodes     | cluster           | template  | yes   |
        | variables.cluster-size-7.nodes     | cluster           | template  | yes   |
        | variables.cluster-size-8.nodes     | cluster           | template  | yes   |
        | variables.cluster-size-9.nodes     | cluster           | template  | yes   |
        | variables.cluster-size-10.nodes    | cluster           | template  | yes   |
        | variables.virtualMachineSettings.imagePublisher     | marklogic            | template  | yes   |
        | variables.virtualMachineSettings.imageOffer         | marklogic_80-preview | template  | yes   |
        | variables.virtualMachineSettings.imageSKU           | ml_centos            | template  | yes   |
        | variables.virtualMachineSettings.imageVersion       | latest               | template  | yes   |
        
        
        
       

    Scenario Outline: Key contains a value.
        When <key> is the key on <type> file
        Then value <should> contain <value>

        Examples:
        | key                      | value                                 | type          | should    |
        #template.json
        |  $schema                 | 2015-01-01/deploymentTemplate.json    | template      | yes       |

        #parameters.json
        |  testKey                 |                                       | params        | yes       |
      
 