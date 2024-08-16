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
import workflow_mgt_service.'error;
import workflow_mgt_service.util;

import ballerina/persist;
import ballerina/uuid;
import ballerina/time;
import ballerina/log;
import ballerina/sql;


final Client dbClient = check new ();

//get all workflow definitions
public isolated function getWorkflowDefinitions(util:Context context) returns types:WorkflowDefinition[]| error {
    do {
        stream<WorkflowDefinition, persist:Error?> streamResult = dbClient->/workflowdefinitions();
        types:WorkflowDefinition[] dbWkfDefinitions = [];
        check from WorkflowDefinition defFromDb in streamResult
        do {
            string[] stringApproverTypes = stringToStringArray(defFromDb.approverTypes);
            types:ApproverType[] approverTypes = [];
            foreach string stringApproverType in stringApproverTypes{
                approverTypes.push(<types:ApproverType>stringApproverType);
            }
            types:WorkflowDefinition wkfDefinition = {
                id: defFromDb.id,
                name: defFromDb.name,
                description: defFromDb.description ?: "",
                approverTypes: approverTypes,
                executeUponApproval: defFromDb.executeUponApproval,
                allowParallelRequests: defFromDb.allowParallelRequests,
                requestFormatSchema: check deserialiseSchema(defFromDb.requestFormatSchema)
            };
            dbWkfDefinitions.push(wkfDefinition);
        };
        return dbWkfDefinitions;
    } on fail error e {
        string message = "Error while retrieving workflow definitions from the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e);
    }
}

//get single workflow definition
public isolated function getWorkflowDefinition(string workflowDefinitionId) returns types:WorkflowDefinition| error {
    do {
        WorkflowDefinition dbWkfDefinition = check dbClient->/workflowdefinitions/[workflowDefinitionId].get();
        string[] stringApproverTypes = stringToStringArray(dbWkfDefinition.approverTypes);
        types:ApproverType[] approverTypes = [];
        foreach string stringApproverType in stringApproverTypes{
            approverTypes.push(<types:ApproverType>stringApproverType);
        }
        types:WorkflowDefinition wkfDefinition = {
            id: dbWkfDefinition.id,
            name: dbWkfDefinition.name,
            description: dbWkfDefinition.description ?: "",
            approverTypes: approverTypes,
            executeUponApproval: dbWkfDefinition.executeUponApproval,
            allowParallelRequests: dbWkfDefinition.allowParallelRequests,
            requestFormatSchema: check deserialiseSchema(dbWkfDefinition.requestFormatSchema)
        };
        return wkfDefinition;
    } on fail error e {
        string message = "Error while retrieving workflow definition from the database";
        log:printError(message, 'error = e);
        return error error:DatabaseError(message, e, wkfDefinitionId = workflowDefinitionId);
    }
}
public isolated function persistWorkflowConfig(util:Context context, types:OrgWorkflowConfigRequest wkfConfigReq) returns types:OrgWorkflowConfig| error {
    do {
        string workflowConfigUuid = uuid:createType1AsString();
        string assigneeRoles = stringArrayToString(wkfConfigReq.assigneeRoles);
        string assignees = stringArrayToString(wkfConfigReq.assignees);
        OrgWorkflowConfigInsert insertData = {
            id: workflowConfigUuid,
            orgId: context.orgId,
            workflowDefinitionId: wkfConfigReq.workflowDefinitionId,
            assigneeRoles: assigneeRoles,
            assignees: assignees,
            formatRequestData: wkfConfigReq.formatRequestData,
            externalWorkflowEngineEndpoint: wkfConfigReq.externalWorkflowEngineEndpoint
        };
        string[] dbResult = check dbClient->/orgworkflowconfigs.post([insertData]);
        if dbResult.length() == 1 {
            types:OrgWorkflowConfig insertedWkfConfig = {
                id: dbResult[0],
                orgId: context.orgId,
                workflowDefinitionId: wkfConfigReq.workflowDefinitionId,
                assigneeRoles: wkfConfigReq.assigneeRoles,
                assignees: wkfConfigReq.assignees,
                formatRequestData: wkfConfigReq.formatRequestData,
                externalWorkflowEngineEndpoint: wkfConfigReq.externalWorkflowEngineEndpoint
            };
            return insertedWkfConfig;
        } else {
            string message = "Error while inserting workflow configuration to the database";
            return error error:DatabaseError(message, wkfDefinitionId = wkfConfigReq.workflowDefinitionId);
        }
    } on fail error e {
        string message = "Error while inserting workflow configuration to the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e, wkfDefinitionId = wkfConfigReq.workflowDefinitionId);
    }
}

public isolated function getWorkflowConfigById(util:Context context, string workflowConfigId) returns types:OrgWorkflowConfig| error {
    do {
        OrgWorkflowConfig dbWkfConfig = check dbClient->/orgworkflowconfigs/[workflowConfigId].get();
        types:OrgWorkflowConfig wkfConfig = {
            id: dbWkfConfig.id,
            orgId: dbWkfConfig.orgId,
            workflowDefinitionId: dbWkfConfig.workflowDefinitionId,
            assigneeRoles: stringToStringArray(dbWkfConfig.assigneeRoles),
            assignees: stringToStringArray(dbWkfConfig.assignees),
            formatRequestData: dbWkfConfig.formatRequestData,
            externalWorkflowEngineEndpoint: dbWkfConfig.externalWorkflowEngineEndpoint
        };
        return wkfConfig;
    } on fail error e {
        string message = "Error while retrieving workflow configuration from the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e, workflowConfigId = workflowConfigId);
    }
}

//get workflow config by org id and workflow definition id
public isolated function getWorkflowConfigByOrgAndDefinition(util:Context context, string workflowDefinitionId) returns types:OrgWorkflowConfig| error {
    do {

        OrgWorkflowConfig[] wkfConfigs = check from OrgWorkflowConfig config in dbClient->/orgworkflowconfigs(OrgWorkflowConfig)
                            where config.orgId == context.orgId &&
                            config.workflowDefinitionId == workflowDefinitionId
                            select config;
        if (wkfConfigs.length() == 0) {
            return error error:ResourceNotFoundError("Workflow configuration not found for the given organization and workflow definition");
        } else if (wkfConfigs.length() > 1) {
            return error error:DatabaseError("Multiple workflow configurations found for the given organization and workflow definition");
        } else {
            OrgWorkflowConfig dbWkfConfig = wkfConfigs[0];
            types:OrgWorkflowConfig wkfConfig = {
                id: dbWkfConfig.id,
                orgId: dbWkfConfig.orgId,
                workflowDefinitionId: dbWkfConfig.workflowDefinitionId,
                assigneeRoles: stringToStringArray(dbWkfConfig.assigneeRoles),
                assignees: stringToStringArray(dbWkfConfig.assignees),
                formatRequestData: dbWkfConfig.formatRequestData,
                externalWorkflowEngineEndpoint: dbWkfConfig.externalWorkflowEngineEndpoint
            };
            return wkfConfig;
        }
    } on fail error e {
        string message = string `Error while retrieving workflow configuration from the database. orgId: ${context.orgId}, workflowDefinitionId: ${workflowDefinitionId}`;
        util:logError(context, message, e);
        return error error:DatabaseError(message, e, workflowDefinitionId = workflowDefinitionId);
    }
}

public isolated function updateWorkflowConfigById(util:Context context, string workflowConfigId, types:OrgWorkflowConfigRequest wkfConfigReq) returns types:OrgWorkflowConfig| error {
    do {
        string assigneeRoles = stringArrayToString(wkfConfigReq.assigneeRoles);
        string assignees = stringArrayToString(wkfConfigReq.assignees);
        OrgWorkflowConfigUpdate updateData = {
            orgId: context.orgId,
            workflowDefinitionId: wkfConfigReq.workflowDefinitionId,
            assigneeRoles: assigneeRoles,
            assignees: assignees,
            formatRequestData: wkfConfigReq.formatRequestData,
            externalWorkflowEngineEndpoint: wkfConfigReq.externalWorkflowEngineEndpoint
        };
        OrgWorkflowConfig dbWkfConfig = check dbClient->/orgworkflowconfigs/[workflowConfigId].put(updateData);
        types:OrgWorkflowConfig wkfConfig = {
            id: dbWkfConfig.id,
            orgId: dbWkfConfig.orgId,
            workflowDefinitionId: dbWkfConfig.workflowDefinitionId,
            assigneeRoles: stringToStringArray(dbWkfConfig.assigneeRoles),
            assignees: stringToStringArray(dbWkfConfig.assignees),
            formatRequestData: dbWkfConfig.formatRequestData,
            externalWorkflowEngineEndpoint: dbWkfConfig.externalWorkflowEngineEndpoint
        };
        return wkfConfig;
    } on fail error e {
        string message = "Error while updating workflow configuration in the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e, wkfConfigId = workflowConfigId);
    }
}

public isolated function deleteWorkflowConfigById(util:Context context, string workflowConfigId) returns types:OrgWorkflowConfig|error {
    do {
        OrgWorkflowConfig deletedDbWkfConfig = check dbClient->/orgworkflowconfigs/[workflowConfigId].delete();
        types:OrgWorkflowConfig deletedWkfConfig = {
            id: deletedDbWkfConfig.id,
            orgId: deletedDbWkfConfig.orgId,
            workflowDefinitionId: deletedDbWkfConfig.workflowDefinitionId,
            assigneeRoles: stringToStringArray(deletedDbWkfConfig.assigneeRoles),
            assignees: stringToStringArray(deletedDbWkfConfig.assignees),
            formatRequestData: deletedDbWkfConfig.formatRequestData,
            externalWorkflowEngineEndpoint: deletedDbWkfConfig.externalWorkflowEngineEndpoint
        };
        return deletedWkfConfig;
    } on fail error e {
        string message = "Error while deleting workflow configuration from the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e, workflowConfigId = workflowConfigId);
    }
}

//For UI

public isolated function searchWorkflowInstances(util:Context context, int 'limit,
        int offset, string wkfDefinition, string status,
        string 'resource, string createdBy) returns stream<AnnotatedWkfInstanceWithRelations, persist:Error?>|error {
    do {
            //filter by orgId and user also
            //with pagination
            //Filter by org
            //Sort by created time
            //Join with workflow definition
            sql:ParameterizedQuery selectQuery = `SELECT wi.id, wi.org_id, wi.resource, wi.created_by, wi.created_time, wi.request_comment, wi.status, wi.reviewed_by, wi.reviewer_decision, wi.review_comment, wi.review_time, wi.org_workflow_config_id, wd.id, wd.name, wd.description, wc.assignee_roles, wc.assignees, wc.format_request_data, wc.external_workflow_engine_endpoint FROM workflow_instance wi JOIN workflow_definition wd ON wi.workflow_definition_id = wd.id JOIN org_workflow_config wc ON wi.org_workflow_config_id = wc.id WHERE wi.org_id = ${context.orgId} and wi.created_by = ${createdBy} and wi.resource = ${'resource} and wi.workflow_definition_id = ${wkfDefinition} and wi.status = ${status} ORDER BY wi.created_time OFFSET ${offset} ROW FETCH FIRST ${'limit} ROWS ONLY`;
            stream<AnnotatedWkfInstanceWithRelations, persist:Error?> resultStream = dbClient->queryNativeSQL(selectQuery);
            return resultStream;
    } on fail error e {
        string message = "Error while retrieving workflow instances from the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e);
    }
}



public isolated function getWorkflowInstanceById(util:Context context, string workflowInstanceId) returns types:WorkflowInstance|error {
    do {
        WorkflowInstance dbWkfInstance = check dbClient->/workflowinstances/[workflowInstanceId].get();
        types:WorkflowInstance wkfInstance = {
            id: dbWkfInstance.id,
            orgId: dbWkfInstance.orgId,
            createdTime: dbWkfInstance.createdTime,
            createdBy: dbWkfInstance.createdBy,
            context: {
                workflowDefinitionIdentifier: dbWkfInstance.workflowDefinitionId,
                'resource: dbWkfInstance.'resource
            },
            requestComment: dbWkfInstance.requestComment,
            orgWorkflowConfigId: dbWkfInstance.orgWorkflowConfigId,
            reviewerDecision: {
                reviewedBy: dbWkfInstance.reviewedBy,
                decision: check dbWkfInstance.reviewerDecision.cloneWithType(),
                reviewComment: dbWkfInstance.reviewComment
            },
            status: check dbWkfInstance.status.cloneWithType()
        };
        return wkfInstance;

    } on fail error e {
        string message = "Error while retrieving workflow instance from the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e, workflowInstanceId = workflowInstanceId);
    }
}

public isolated function getWorkflowInstanceResponseById(util:Context context, string workflowInstanceId) returns types:WorkflowInstanceResponse|error {
    do {
        WorkflorInstanceWithDefinitionDetails dbWkfInstance = check dbClient->/workflowinstances/[workflowInstanceId].get();
        types:WorkflowInstanceResponse wkfInstance = {
            wkfId: dbWkfInstance.id,
            orgId: dbWkfInstance.orgId,
            createdTime: dbWkfInstance.createdTime,
            createdBy: dbWkfInstance.createdBy,
            context: {
                workflowDefinitionIdentifier: dbWkfInstance.workflowDefinitionId,
                'resource: dbWkfInstance.'resource
            },
            workflowDefinitionIdentifier: {
                id: dbWkfInstance.workflowDefinition.id,
                name: dbWkfInstance.workflowDefinition.name,
                description: dbWkfInstance.workflowDefinition.description
            },
            requestComment: dbWkfInstance.requestComment,
            reviewerDecision: {
                reviewedBy: dbWkfInstance.reviewedBy,
                decision: check dbWkfInstance.reviewerDecision.cloneWithType(),
                reviewComment: dbWkfInstance.reviewComment
            },
            status: check dbWkfInstance.status.cloneWithType()
        };
        return wkfInstance;

    } on fail error e {
        string message = "Error while retrieving workflow instance from the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e, workflowInstanceId = workflowInstanceId);
    }
}


public isolated function persistWorkflowInstance(util:Context context, types:WorkflowInstanceCreateRequest wkfInstanceReq) returns string|error {
    do {
        string workflowInstanceUuid = uuid:createType1AsString();
        time:Utc createdTime = time:utcNow();

        //find workflow config related to the operation in the organization
        types:OrgWorkflowConfig orgWkfConfig = check getWorkflowConfigByOrgAndDefinition(context, wkfInstanceReq.context.workflowDefinitionIdentifier);

        WorkflowInstanceInsert insertData = {
            id: workflowInstanceUuid,
            orgId: context.orgId,
            createdBy: context.userId,
            createdTime: createdTime,
            requestComment: wkfInstanceReq.requestComment?: "",
            data: wkfInstanceReq.data.toJsonString(),
            status: types:PENDING,
            reviewedBy: (),
            reviewerDecision: (),
            reviewComment: (),
            reviewTime: (),
            orgWorkflowConfigId: orgWkfConfig.id,
            workflowDefinitionId: wkfInstanceReq.context.workflowDefinitionIdentifier,
            'resource: wkfInstanceReq.context.'resource
        };
        string[] dbResult = check dbClient->/workflowinstances.post([insertData]);
        if dbResult.length() == 1 {
            return dbResult[0];
        } else {
            string message = "Error while inserting workflow instance to the database";
            return error error:DatabaseError(message, wkfInstanceId = workflowInstanceUuid);
        }
    } on fail error e {
        string message = "Error while inserting workflow instance to the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e);
    }
}

//delete workflow instance
public isolated function deleteWorkflowInstance(util:Context context, string workflowInstanceId) returns string|error {
    do {
        WorkflowInstance dbWkfInstance = check dbClient->/workflowinstances/[workflowInstanceId].delete();
        return dbWkfInstance.id;
    } on fail error e {
        string message = "Error while deleting workflow instance from the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e, workflowInstanceId = workflowInstanceId);
    }
}

public isolated function getWorkflowInstanceData(util:Context context, string workflowInstanceId) returns json|error {   //TODO: can we only get data?
    do {
        WorkflowInstance dbWkfInstance = check dbClient->/workflowinstances/[workflowInstanceId].get();
        return dbWkfInstance.data;
    } on fail error e {
        string message = "Error while retrieving workflow instance data from the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e, workflowInstanceId = workflowInstanceId);
    }
}

public isolated function getWorkflowInstance(util:Context context, string workflowDefinition, string 'resource) returns types:WorkflowInstance|error {
    do {
        WorkflowInstance[] instances = check from WorkflowInstance instance in dbClient->/workflowinstances(WorkflowInstance)
                            where instance.'resource == 'resource &&
                            instance.workflowDefinitionId == workflowDefinition
                            select instance;
        if instances.length() == 0 {
            return error error:ResourceNotFoundError("Workflow instance not found for the given workflow definition and resource");
        } else if instances.length() > 1 {
            return error error:DatabaseError("Multiple workflow instances found for the given workflow definition and resource. Is resource unique?");
        } else {
            WorkflowInstance dbWkfInstance = instances[0];
            types:WorkflowInstance wkfInstance = {
                id: dbWkfInstance.id,
                orgId: dbWkfInstance.orgId,
                createdTime: dbWkfInstance.createdTime,
                createdBy: dbWkfInstance.createdBy,
                context: {
                    workflowDefinitionIdentifier: dbWkfInstance.workflowDefinitionId,
                    'resource: dbWkfInstance.'resource
                },
                requestComment: dbWkfInstance.requestComment,
                orgWorkflowConfigId: dbWkfInstance.orgWorkflowConfigId,
                reviewerDecision: {
                    reviewedBy: dbWkfInstance.reviewedBy,
                    decision: check dbWkfInstance.reviewerDecision.cloneWithType(),
                    reviewComment: dbWkfInstance.reviewComment
                },
                status: check dbWkfInstance.status.cloneWithType()
            };
            return wkfInstance;
        }
    } on fail error e {
        string message = string `Error while retrieving workflow instance from the database
        for workflow definition: ${workflowDefinition} and resource: ${'resource}`;
        util:logError(context, message, e);
        return error error:DatabaseError(message, e);
    }
}

//persist audit event
public isolated function persistAuditEvent(util:Context context, types:AuditEvent auditEvent) returns string|error {
    do {
        string auditEventUuid = uuid:createType1AsString();
        AuditEventInsert insertData = {
            id: auditEventUuid,
            orgId: context.orgId,
            eventType: auditEvent.eventType,
            timestamp: auditEvent.timestamp,
            userId: context.userId,
            workflowDefinitionId: auditEvent.workflowDefinition.id,
            'resource: auditEvent.'resource,
            workflowInstanceId: auditEvent.workflowInstanceId,
            comment: auditEvent.comment
        };
        string[] dbResult = check dbClient->/auditevents.post([insertData]);
        if dbResult.length() == 1 {
            return dbResult[0];
        } else {
            string message = "Error while inserting audit event to the database";
            return error error:DatabaseError(message, auditEventId = auditEventUuid);
        }
    } on fail error e {
        string message = "Error while inserting audit event to the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e);
    }
}

//search audit events
public isolated function searchAuditEvents(util:Context context, int 'limit, int offset, string wkfDefinitionId, string status, string 'resource, string eventType, string userId) returns types:AuditEvent[]|error {
    do {

        sql:ParameterizedQuery selectQuery = `SELECT ae.id, ae.org_id, ae.event_type, ae.timestamp, ae.user_id, ae.resource, ae.workflow_instance_id, ae.comment, wd.id, wd.name, wd.description FROM audit_event ae JOIN workflow_definition wd ON ae.workflow_definition_id = wd.id WHERE ae.org_id = ${context.orgId} and ae.action = ${wkfDefinitionId} and ae.status = ${status} and ae.resource = ${'resource} and ae.event_type = ${eventType} and ae.user_id = ${userId} ORDER BY ae.timestamp OFFSET ${offset} ROW FETCH FIRST ${'limit} ROWS ONLY`;

        stream<AuditEventWithRelations, persist:Error?> resultStream = dbClient->queryNativeSQL(selectQuery);
        types:AuditEvent[] auditEvents = [];
        check from AuditEventWithRelations auditEvent in resultStream
        do {
            types:AuditEvent event = {
                id: auditEvent.id,
                orgId: auditEvent.orgId,
                timestamp: auditEvent.timestamp,
                eventType: check auditEvent.eventType.cloneWithType(),
                user: auditEvent.userId,
                'resource: auditEvent.'resource,
                workflowInstanceId: auditEvent.workflowInstanceId,
                comment: auditEvent.comment,
                workflowDefinition: {
                    id: auditEvent.workflowDefinition.id,
                    name: auditEvent.workflowDefinition.name,
                    description: auditEvent.workflowDefinition.description
                }
            };
            auditEvents.push(event);
        };
        return auditEvents;
    } on fail error e {
        string message = "Error while searching audit events from the database";
        util:logError(context, message, e);
        return error error:DatabaseError(message, e);
    }
}
