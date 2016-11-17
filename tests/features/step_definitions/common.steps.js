/**

    TODO:
    - Key contains a value
    - 

 */

/*====================================
=            Common Steps            =
====================================*/

/**
 *
 * Hosts all the commonly used steps that can used accross all the other step definitions
 *
 */

'use strict';

module.exports = function(){

    var objectPath = require("object-path");
    this.World = require('../support/arm-template-validator.js').World;
    this.template_JSON = {};
    this.template_param_JSON = {};
    this.tempValue = "";
 	
    /**
     *	Givens
   	*/	
    this.Given(/^I have opened the "([^"]*)" template$/, function (fileName, callback) {
        try{
           this.template_JSON = require(process.cwd()+fileName);
           this.template_param_JSON = require(process.cwd()+fileName.replace('.json','.parameters.json'));
	       callback();
        }catch(ex){
	    	callback(new Error("Azure template cannot be read or not a valid json"));
        }
    });
    
    this.Given(/^I uploaded the template to Validator$/, function (callback) {  
        this.validateTemplate(callback);
    });   


    /**
    *	Whens
    */
    this.When("$key is the key",function(key, callback){
        if(objectPath.has(this.template_JSON, key)){
            this.tempValue = objectPath.get(this.template_JSON, key);
            callback();
        }else{
            callback(new Error("Key cannot be found"));
        }
    });

    this.When("$key is the key on $type file", function (key, fileType, callback) {
        if(fileType === "template"){
            if(objectPath.has(this.template_JSON, key)){
                this.tempValue = objectPath.get(this.template_JSON, key);
                callback();
            }else{
                callback(new Error("Template does not have the key"+key));
            }
        }else if(fileType === "params"){
            if(objectPath.has(this.template_param_JSON, key)){
                this.tempValue = objectPath.get(this.template_param_JSON, key);
                callback();
            }else{
                callback(new Error("Params does not have the key"+key));
            }
        }else{
            callback(new Error("incorrect file type, should be either template or params."));
        }
    });    


   /**
    *	Thens
    */
    this.Then("$key $is present in the $type file", function (key, is, fileType, callback) {
        var tempJson = "";
        if(fileType === "template"){
            tempJson = this.template_JSON;
        }else if(fileType === "params"){
            tempJson = this.template_param_JSON;
        }else{
            callback(new Error("incorrect file type, should be either template or params."));
        }
        if(tempJson){
            if(is === "yes"){
                (objectPath.has(tempJson, key)) ? callback() : callback(new Error("The key should be present, but it does not."));
            }else{
                (objectPath.has(tempJson, key)) ? callback(new Error("The key should not be present, but it does.")) : callback();
            }
        }
    });

    this.Then("update the $key on file $type to $value",function(key, fileType, value, callback){
        if(fileType === "template"){
            if(objectPath.has(this.template_JSON, key)){
                this.template_JSON[key] = value;
            }else{
                callback(new Error("Key should be present, but does not."));
            }
        }else if(fileType === "params"){
            if(objectPath.has(this.template_param_JSON, key)){
                this.template_param_JSON[key] = value;
            }else{
                callback(new Error("Key should be present, but does not."));
            }
        }else{
            callback(new Error("incorrect file type, should be either template or params."));
        }
    });

    this.Then("$value $should be its value", function (value, should, callback) {
        if(should === "yes"){
            if(this.tempValue === value){
                callback();
            }else{
                callback(new Error("value should match, but it does not actually match."));
            }
        }else if(should === "no"){
            if(this.tempValue === value){
                callback(new Error("value should not match, but it actually matches."));
            }else{
                callback();
            }
        }else{
            callback(new Error("incorrect verb type, value should either be yes or no."));
        }
    });    
  	

    this.Then(/^It should return a sucess payload$/, function (callback) {
        callback();              
    });

    this.Then("Its value has matching braces and quotes", function (callback) {
        try{
            new Function(this.tempValue);
            callback();
        }catch(err){
            callback(new Error("The Key value has an unmatched braces or quotes"));
        }
    });

    this.Then("value $should contain $value", function (_should, _value, callback) {
        if(_should === "yes"){
            if(this.tempValue.indexOf(_value) > -1){
                callback();
            }else{
                callback(new Error("value should contain"+_value+", but it does not."));
            }
        }else if(_should === "no"){
            if(this.tempValue.indexOf(_value) > -1){
                callback(new Error("value should not contain"+_value+", but it does."));
            }else{
                callback();
            }
        }else{
            callback(new Error("incorrect verb type, value should either be yes or no."));
        }
    });


};


/*=====  End of Common Steps  ======*/