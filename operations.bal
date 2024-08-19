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
import ballerina/http;
import workflow_mgt_service.util;
import workflow_mgt_service.db;
import ballerina/persist;

//default sorting is by requested time
//Get orgId from the context
//if viewed by a manager, show workflows assigned to the manager
//if viewed by a user, show workflows requested by the user
//if viewed by an admin, show all workflows?
public isolated function getWorkflowInstances(util:Context context, int 'limit,
        int offset, string? wkfDefinition, string? status,
        string? 'resource, string? createdBy) returns types:WorkflowInstanceResponse[]|error {

     stream<db:AnnotatedWkfInstanceWithRelations, persist:Error?> dbInstances = check
            db:searchWorkflowInstances(context, 'limit, offset, wkfDefinition, status, 'resource, createdBy);
     return check filterWorkflowInstancesByUser(context, dbInstances);
}

public isolated function ensureWkfConfigBelongsToCorrectOrg(util:Context context, types:OrgWorkflowConfig wkfConfig) returns boolean|error {
    if wkfConfig.orgId == context.orgId {
        return true;
    } else {
        return false;
    }
}

public isolated function ensureWkfInstanceBelongsToCorrectOrg(util:Context context, types:WorkflowInstanceResponse wkfInstance) returns boolean|error {
    if wkfInstance.orgId == context.orgId {
        return true;
    } else {
        return false;
    }
}

isolated function filterWorkflowInstancesByUser(util:Context context, stream<db:AnnotatedWkfInstanceWithRelations, persist:Error?> dbInstances) returns types:WorkflowInstanceResponse[]|error {
    types:WorkflowInstanceResponse[] wkfInstances = [];
    check from db:AnnotatedWkfInstanceWithRelations instance in dbInstances
    do {
        string [] rolesList = db:stringToStringArray(instance.orgWorkflowConfig.assigneeRoles);
        string [] assigneesList = db:stringToStringArray(instance.orgWorkflowConfig.assignees);

        if (check isWorkflowInstanceApprovableForUser(context, rolesList, assigneesList)) {
            types:WorkflowInstanceResponse wkfInstance = {
                wkfId: instance.id,
                orgId: instance.orgId,
                createdTime: instance.createdTime,
                createdBy: instance.createdBy,
                context: {
                    workflowDefinitionIdentifier: instance.workflowDefinition.id,
                    'resource: instance.'resource
                },
                workflowDefinitionIdentifier: {
                    id: instance.workflowDefinition.id,
                    name: instance.workflowDefinition.name,
                    description: instance.workflowDefinition.description
                },
                requestComment: instance.requestComment,
                status: check instance.status.cloneWithType()
            };

            if instance.reviewerDecision != () && instance.reviewerDecision != "" {
                wkfInstance.reviewerDecision = {
                    reviewedBy: instance.reviewedBy,
                    decision: check instance.reviewerDecision.cloneWithType(),
                    reviewComment: instance.reviewComment
                };
            }
            wkfInstances.push(wkfInstance);
        }
    };
    return wkfInstances;
}

isolated function isWorkflowInstanceApprovableForUser(util:Context context, string[] rolesList, string[] assigneesList) returns boolean|error {
    return true;
}

public isolated function formatDataForReviewer(string workflowInstanceId, json data) returns json | error {
    return data;
}

//if parallel requests are not allowed, check if there is a request in progress and get the status
//if not no need to check the status
//used by UI for button text rendering
public isolated function getWorkflowStatus(http:RequestContext ctx, string wkfDefinitionId, string 'resource) returns types:WorkflowMgtStatus | error  {
    return "APPROVED";
}
