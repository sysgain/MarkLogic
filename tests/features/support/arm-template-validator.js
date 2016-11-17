/*==============================================================================
=            Validates the Template against the Azure API validator            =
==============================================================================*/

'use strict';

var World = function(callback){

	var msRestAzure = require('ms-rest-azure');
	var ResourceManagementClient = require('azure-arm-resource').ResourceManagementClient;
	var resourceClient;

	//Sample Config
	var clientId = process.env['CLIENT_ID'];//"c97638e8-5df0-45f4-8d9e-3b48eaa62de9";
	var domain = process.env['DOMAIN'];//"dcf9e4d3-f44a-4c28-be12-8245c0d35668";//
	var secret = process.env['APPLICATION_SECRET'];//"2rY1hOo7F3ELAMJxk4z+nSun/zfTbPvD9CQ2msOy2Ag=";//
	var subscriptionId = process.env['AZURE_SUBSCRIPTION_ID'];//"7eab3893-bd71-4690-84a5-47624df0b0e5";//
	var randomIds = {};
	var location = 'westus';
	var resourceGroupName = process.env['RESOURCE_GROUP_NAME'];//'sysgainTestRG5966';//generateRandomId('sysgainTestRG', randomIds);
	var deploymentName = generateRandomId('sysgainTestDeployment', randomIds);
	var parameters = {};
	var options = {};

  	function generateRandomId(prefix, exsitIds) {
  		var newNumber;
  		while (true) {
    		newNumber = prefix + Math.floor(Math.random() * 10000);
    		if (!exsitIds || !(newNumber in exsitIds)) {
      			break;
    		}
  		}
  		return newNumber;
	}

	function stubParams(_obj){
		if(_obj.hasOwnProperty("dnsLabelPrefix")){
			_obj.dnsLabelPrefix.value = "sysgain789";
		}
		return _obj;
	}

	this.validateTemplate = function(callback){
		var that = this;	
		try{
			msRestAzure.loginWithServicePrincipalSecret(clientId, secret, domain, function (err, credentials) {
				if (err){
					callback(new Error(err+" error authenticating using service principal"));
				}else{
					resourceClient = new ResourceManagementClient(credentials, subscriptionId);
					var deploymentParameters = {
						"properties": {
							"template":that.template_JSON,
							"parameters":stubParams(that.template_param_JSON.parameters),
							"mode": "Incremental"
		    			}
		    		};
					resourceClient.deployments.validate(resourceGroupName, deploymentName, deploymentParameters, options, function(err, result, request, response){
						if (err){
							callback(new Error(err+" error validating template"));
						}else if(result.hasOwnProperty("properties") && result.properties.hasOwnProperty("provisioningState")){
							callback();
						}else{
							callback(new Error(JSON.stringify(result) + " error returned from the template validator"));
						}
					});
				}
			});
		}catch(ex){
			callback(new Error(ex + " error validating template"));	
		}
	};

};	

exports.World = World;


/*=====  End of Validates the Template against the Azure API validator  ======*/
