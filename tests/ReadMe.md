#Testing Framework

##Directory Structure
##Feature File
##Steps
```gherkin
Background: 
	Given I have opened the "/vnet-subnet/vnet-subnet.json" template
```
```gherkin
Scenario: Validate the Template Against the Azure Validator
	Given I uploaded the template to Validator
    Then It should return a sucess payload
```
```gherkin
Scenario Outline: Key is/not Present.
	Then  <key> <is> present in the <type> file
    
    Examples:
    | key                               | is    | type      |
    #Template.json
    | $schema                           | yes   | template  |
    #parameters.json
    | parameters.location.value         | yes   | params    |
```
```gherkin
Scenario Outline: Key has/not a specific value.
	When <key> is the key on <type> file
    Then <value> <should> be its value
    
    Examples:
    | key                                | value                                                                                    | type      | should  |
    #Template.json
    | $schema                            | https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#          | template  | yes     |
    #parameters.json
    | parameters.vnetAddressPrefix.value | 10.0.0.0/16                                                                              | params    | yes     |
```
```gherkin
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
```
```gherkin
Scenario Outline: Update Key's Value.
    Then update the <key> on file <type> to <value>

    Examples:
    | key                       | type              | value         |
    | parameters.username.value | params            | testrg1234    |    
```
```gherkin
Scenario Outline: Check Functions for matching quotes and braces.
    When <key> is the key on <type> file
    Then Its value has matching braces and quotes

    Examples:
    | key               | type      |
    | resources.0.name  | template  |
```
##Note
> Always keep your branch Synced with `Staging` to get updated `Step Definitions`

to sync merge create a pull request assigning it to yourself.

![](https://armbaseartifacts.blob.core.windows.net/arm-base/arm-base-images/sync-merge.PNG)

once merging pull request do not forget to pull the changes to your local using vscode and your branch selected.
