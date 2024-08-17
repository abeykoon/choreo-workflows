// Copyright (c) 2024 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import workflow_mgt_service.types;

public isolated function stringArrayToString(string[] arr) returns string {
    string result = "";
    foreach string item in arr {
        result = result + item + ",";
    }
    // Remove the trailing comma
    result = result.substring(0, result.length() - 1);
    return result;
}

public isolated function stringToStringArray(string str) returns string[] {
    string:RegExp r = re `,`;
    return r.split(str);
}

public isolated function serialiseSchema(map <types:FormatSchemaEntry> schema) returns string {
    string jsonString = schema.toJsonString();
    return jsonString;
}

public isolated function deserialiseSchema(string schema) returns map <types:FormatSchemaEntry>|error {
    json jsonData = check schema.fromJsonString();
    map<types:FormatSchemaEntry> target = check jsonData.cloneWithType();
    return target;
}
