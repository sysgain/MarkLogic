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
        | parameters.dataDiskStorageAccountType | yes   | template  |
        | variables.storageSettings             | yes   | template  | 
        | variables.storageSettings.osDiskStorage       | yes   | template  | 
        | variables.storageSettings.dataDiskStorage     | yes   | template  |
        | variables.storageSettings.osDiskStorage.location       | yes   | template  | 
        | variables.storageSettings.dataDiskStorage.location     | yes   | template  |
       
        | resources.0.properties.parameters.templateUrls           | yes   | template  |
        | resources.0.properties.parameters.networkSettings        | yes   | template  |
        | resources.0.properties.parameters.storageAccountSettings | yes   | template  |
        
        

    Scenario Outline: Key has/not a specific value.
      When <key> is the key on <type> file
      Then <value> <should> be its value

      Examples:
        | key                                | value                                                                              | type      | should  |
        #Template.json
        | $schema                            | https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#    | template  | yes     |
        | contentVersion                     | 1.0.0.0                                                                            | template  | yes     |
        | variables.storageSettings.osDiskStorage.storageAccountType    | Standard_LRS                                | template  | yes     |
        | variables.storageSettings.dataDiskStorage.storageAccountType  | [parameters('dataDiskStorageAccountType')]  | template  | yes     |
        | variables.virtualMachineSettings.dataDiskSizeGB               | 1023      | template      | yes       |
        | variables.virtualMachineSettings.osDiskStorageAccountName     | [variables('storageSettings').osDiskStorage.storageAccountName]      | template  | yes   |
        | variables.virtualMachineSettings.dataDiskStorageAccountName   | [variables('storageSettings').dataDiskStorage.storageAccountName]    | template  | yes   |
        | parameters.dataDiskStorageAccountType.allowedValues.0         | Standard_LRS | template  | yes   |
        | parameters.dataDiskStorageAccountType.allowedValues.1         | Premium_LRS  | template  | yes   | 

        

        
        
        
       

    Scenario Outline: Key contains a value.
        When <key> is the key on <type> file
        Then value <should> contain <value>

        Examples:
        | key                      | value                                 | type          | should    |
        #template.json
        |  $schema                 | 2015-01-01/deploymentTemplate.json    | template      | yes       |

      