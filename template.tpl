___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Dark Social tracker for Page URL by MeasureMinds",
  "categories": [
    "UTILITY"
  ],
  "description": "If URL doesn\u0027t have UTM params but has Click ID. The template add utm_source and utm_medium based on the list of advertising Click ID query parameters. For example: fbclid, twclid, ttclid and so on.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "url",
    "displayName": "URL",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "params",
    "displayName": "Query Parameters",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Parameter",
        "name": "param",
        "type": "TEXT",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ]
      },
      {
        "defaultValue": "",
        "displayName": "utm_source",
        "name": "utm_source",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "utm_medium",
        "name": "utm_medium",
        "type": "TEXT"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Load library functions
const parseUrl = require("parseUrl");
const makeTableMap = require("makeTableMap");
const Object = require("Object");
const log = require("logToConsole");

// Declare inputs
const paramTable = data.params; // TABLE
const url = data.url; // URL E.G. location.HREF

// Parse inputs
const utm_sources = makeTableMap(paramTable, "param", "utm_source"); // e.g. fbclk || facebook.com || referral
const utm_mediums = makeTableMap(paramTable, "param", "utm_medium"); // e.g. fbclk || facebook.com || referral
const urlObj = parseUrl(url);
const searchParams = urlObj.searchParams; // PP said urlObj.hash not accounted for
let searchParamsNames = Object.keys(searchParams);

if(urlObj.hash.length>0){
    const testUrl = 'https://test.com?'+urlObj.hash.substring(1);
    const testUrlObj = parseUrl(testUrl);
    const searchParamsNamesTest = Object.keys(testUrlObj.searchParams);
    searchParamsNames = searchParamsNames.concat(searchParamsNamesTest);
}


// Declare variables
let hasUtm = false;   // Default assume no utm
let hasParam = false; // Default assume no params
let utmSource = "";
let utmMedium = "";

// Dont inject utm_source=facebook.com&utm_medium=referral if utm is already in URL
const params = Object.keys(utm_sources);
const utmParamNamesBlacklist = ["utm_source","utm_medium","utm_campaign"];
for (let index = 0; index < searchParamsNames.length; index++) {
  const searchParam = searchParamsNames[index];
  if (utmParamNamesBlacklist.indexOf(searchParam) > -1) {
    hasParam = false; // param not found
    hasUtm = true;    // utm found
    break;
  }
  if (params.indexOf(searchParam) > -1) {
    hasParam = true;  // param found
    hasUtm = false;   // utm not found
    utmSource = utm_sources[searchParam];
    utmMedium = utm_mediums[searchParam];
  }
}

let output;
if (hasParam===true && hasUtm===false) {
  const newUtms = "utm_source=" + utmSource + "&utm_medium=" + utmMedium;
  const delimeter = urlObj.search.length > 0 ? "&" : "?"; // PP said urlObj.hash not accounted for
  const finalUrl = urlObj.origin + urlObj.pathname + urlObj.search + delimeter + newUtms + urlObj.hash;
  output = finalUrl; // Edited URL
} else {
  output = url; // Default to original URL
}
return output;


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: One parameter
  code: |2-

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);
    const finalUrl = 'https://test.com/?fbclid=123&utm_source=facebook.com&utm_medium=referral';
    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo(finalUrl);
- name: Url with hash
  code: |-
    mockData.url = 'https://test.com?fbclid=123#h=234';

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);
    const finalUrl = 'https://test.com/?fbclid=123&utm_source=facebook.com&utm_medium=referral#h=234';
    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo(finalUrl);
- name: No params
  code: |-
    mockData.url = 'https://test.com?xxx=123#h=234';

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo(mockData.url);
- name: Utm param and params
  code: |-
    mockData.url = 'https://test.com?fbclid=123&utm_source=test#h=234';

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo(mockData.url);
- name: Only domain - test_com/
  code: |-
    mockData.url = 'https://test.com/';

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo(mockData.url);
- name: Url with utm hash - test_com?fbclid=123#utm_source=test
  code: |-
    mockData.url = 'https://test.com?fbclid=123#utm_source=test';

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo(mockData.url);
- name: URL test_com?xxx=123#fbclid=123
  code: |-
    mockData.url = 'https://test.com/path1?xxx=123#fbclid=123';
    const finalUrl = 'https://test.com/path1?xxx=123&utm_source=facebook.com&utm_medium=referral#fbclid=123';

    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);

    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo(finalUrl);
- name: URL test_com/path/?fbclid=123
  code: |-
    mockData.url = "https://test.com/path/test.php?fbclid=123";
    // Call runCode to run the template's code.
    let variableResult = runCode(mockData);
    const finalUrl = 'https://test.com/path/test.php?fbclid=123&utm_source=facebook.com&utm_medium=referral';
    // Verify that the variable returns a result.
    assertThat(variableResult).isEqualTo(finalUrl);
setup: let mockData =  {"params":[{"param":"fbclid","utm_source":"facebook.com","utm_medium":"referral"},{"param":"twclid","utm_source":"trwitter.com","utm_medium":"referral"}],"url":"https://test.com?fbclid=123","gtmEventId":1};


___NOTES___

Created on 15/07/2023, 16:31:51


