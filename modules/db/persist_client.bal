// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/jballerina.java;
import ballerina/persist;
import ballerina/sql;
import ballerinax/persist.sql as psql;
import ballerinax/postgresql;
import ballerinax/postgresql.driver as _;

const WORKFLOW_DEFINITION = "workflowdefinitions";
const AUDIT_EVENT = "auditevents";
const WORKFLOW_INSTANCE = "workflowinstances";
const ORG_WORKFLOW_CONFIG = "orgworkflowconfigs";

public isolated client class Client {
    *persist:AbstractPersistClient;

    private final postgresql:Client dbClient;

    private final map<psql:SQLClient> persistClients;

    private final record {|psql:SQLMetadata...;|} & readonly metadata = {
        [WORKFLOW_DEFINITION]: {
            entityName: "WorkflowDefinition",
            tableName: "workflow_definition",
            fieldMetadata: {
                id: {columnName: "id"},
                name: {columnName: "name"},
                description: {columnName: "description"},
                approverTypes: {columnName: "approver_types"},
                executeUponApproval: {columnName: "execute_upon_approval"},
                allowParallelRequests: {columnName: "allow_parallel_requests"},
                requestFormatSchema: {columnName: "request_format_schema"},
                "orgworkflowconfigs[].id": {relation: {entityName: "orgworkflowconfigs", refField: "id"}},
                "orgworkflowconfigs[].orgId": {relation: {entityName: "orgworkflowconfigs", refField: "orgId", refColumn: "org_id"}},
                "orgworkflowconfigs[].assigneeRoles": {relation: {entityName: "orgworkflowconfigs", refField: "assigneeRoles", refColumn: "assignee_roles"}},
                "orgworkflowconfigs[].assignees": {relation: {entityName: "orgworkflowconfigs", refField: "assignees"}},
                "orgworkflowconfigs[].formatRequestData": {relation: {entityName: "orgworkflowconfigs", refField: "formatRequestData", refColumn: "format_request_data"}},
                "orgworkflowconfigs[].externalWorkflowEngineEndpoint": {relation: {entityName: "orgworkflowconfigs", refField: "externalWorkflowEngineEndpoint", refColumn: "external_workflow_engine_endpoint"}},
                "orgworkflowconfigs[].workflowDefinitionId": {relation: {entityName: "orgworkflowconfigs", refField: "workflowDefinitionId", refColumn: "workflow_definition_id"}},
                "workflowinstance[].id": {relation: {entityName: "workflowinstance", refField: "id"}},
                "workflowinstance[].orgId": {relation: {entityName: "workflowinstance", refField: "orgId", refColumn: "org_id"}},
                "workflowinstance[].resource": {relation: {entityName: "workflowinstance", refField: "resource"}},
                "workflowinstance[].createdBy": {relation: {entityName: "workflowinstance", refField: "createdBy", refColumn: "created_by"}},
                "workflowinstance[].createdTime": {relation: {entityName: "workflowinstance", refField: "createdTime", refColumn: "created_time"}},
                "workflowinstance[].requestComment": {relation: {entityName: "workflowinstance", refField: "requestComment", refColumn: "request_comment"}},
                "workflowinstance[].data": {relation: {entityName: "workflowinstance", refField: "data"}},
                "workflowinstance[].status": {relation: {entityName: "workflowinstance", refField: "status"}},
                "workflowinstance[].reviewedBy": {relation: {entityName: "workflowinstance", refField: "reviewedBy", refColumn: "reviewed_by"}},
                "workflowinstance[].reviewerDecision": {relation: {entityName: "workflowinstance", refField: "reviewerDecision", refColumn: "reviewer_decision"}},
                "workflowinstance[].reviewComment": {relation: {entityName: "workflowinstance", refField: "reviewComment", refColumn: "review_comment"}},
                "workflowinstance[].reviewTime": {relation: {entityName: "workflowinstance", refField: "reviewTime", refColumn: "review_time"}},
                "workflowinstance[].orgWorkflowConfigId": {relation: {entityName: "workflowinstance", refField: "orgWorkflowConfigId", refColumn: "org_workflow_config_id"}},
                "workflowinstance[].workflowDefinitionId": {relation: {entityName: "workflowinstance", refField: "workflowDefinitionId"}}
            },
            keyFields: ["id"],
            joinMetadata: {
                orgworkflowconfigs: {entity: OrgWorkflowConfig, fieldName: "orgworkflowconfigs", refTable: "org_workflow_config", refColumns: ["workflow_definition_id"], joinColumns: ["id"], 'type: psql:MANY_TO_ONE},
                workflowinstance: {entity: WorkflowInstance, fieldName: "workflowinstance", refTable: "workflow_instance", refColumns: ["workflowDefinitionId"], joinColumns: ["id"], 'type: psql:MANY_TO_ONE}
            }
        },
        [AUDIT_EVENT]: {
            entityName: "AuditEvent",
            tableName: "audit_event",
            fieldMetadata: {
                id: {columnName: "id"},
                orgId: {columnName: "org_id"},
                eventType: {columnName: "event_type"},
                timestamp: {columnName: "timestamp"},
                userId: {columnName: "user_id"},
                workflowDefinitionId: {columnName: "workflow_definition_id"},
                'resource: {columnName: "resource"},
                workflowInstanceId: {columnName: "workflow_instance_id"},
                comment: {columnName: "comment"}
            },
            keyFields: ["id"]
        },
        [WORKFLOW_INSTANCE]: {
            entityName: "WorkflowInstance",
            tableName: "workflow_instance",
            fieldMetadata: {
                id: {columnName: "id"},
                orgId: {columnName: "org_id"},
                'resource: {columnName: "resource"},
                createdBy: {columnName: "created_by"},
                createdTime: {columnName: "created_time"},
                requestComment: {columnName: "request_comment"},
                data: {columnName: "data"},
                status: {columnName: "status"},
                reviewedBy: {columnName: "reviewed_by"},
                reviewerDecision: {columnName: "reviewer_decision"},
                reviewComment: {columnName: "review_comment"},
                reviewTime: {columnName: "review_time"},
                orgWorkflowConfigId: {columnName: "org_workflow_config_id"},
                workflowDefinitionId: {columnName: "workflowDefinitionId"},
                "orgworkflowconfig.id": {relation: {entityName: "orgworkflowconfig", refField: "id"}},
                "orgworkflowconfig.orgId": {relation: {entityName: "orgworkflowconfig", refField: "orgId", refColumn: "org_id"}},
                "orgworkflowconfig.assigneeRoles": {relation: {entityName: "orgworkflowconfig", refField: "assigneeRoles", refColumn: "assignee_roles"}},
                "orgworkflowconfig.assignees": {relation: {entityName: "orgworkflowconfig", refField: "assignees"}},
                "orgworkflowconfig.formatRequestData": {relation: {entityName: "orgworkflowconfig", refField: "formatRequestData", refColumn: "format_request_data"}},
                "orgworkflowconfig.externalWorkflowEngineEndpoint": {relation: {entityName: "orgworkflowconfig", refField: "externalWorkflowEngineEndpoint", refColumn: "external_workflow_engine_endpoint"}},
                "orgworkflowconfig.workflowDefinitionId": {relation: {entityName: "orgworkflowconfig", refField: "workflowDefinitionId", refColumn: "workflow_definition_id"}},
                "workflowDefinition.id": {relation: {entityName: "workflowDefinition", refField: "id"}},
                "workflowDefinition.name": {relation: {entityName: "workflowDefinition", refField: "name"}},
                "workflowDefinition.description": {relation: {entityName: "workflowDefinition", refField: "description"}},
                "workflowDefinition.approverTypes": {relation: {entityName: "workflowDefinition", refField: "approverTypes", refColumn: "approver_types"}},
                "workflowDefinition.executeUponApproval": {relation: {entityName: "workflowDefinition", refField: "executeUponApproval", refColumn: "execute_upon_approval"}},
                "workflowDefinition.allowParallelRequests": {relation: {entityName: "workflowDefinition", refField: "allowParallelRequests", refColumn: "allow_parallel_requests"}},
                "workflowDefinition.requestFormatSchema": {relation: {entityName: "workflowDefinition", refField: "requestFormatSchema", refColumn: "request_format_schema"}}
            },
            keyFields: ["id"],
            joinMetadata: {
                orgworkflowconfig: {entity: OrgWorkflowConfig, fieldName: "orgworkflowconfig", refTable: "org_workflow_config", refColumns: ["id"], joinColumns: ["org_workflow_config_id"], 'type: psql:ONE_TO_MANY},
                workflowDefinition: {entity: WorkflowDefinition, fieldName: "workflowDefinition", refTable: "workflow_definition", refColumns: ["id"], joinColumns: ["workflowDefinitionId"], 'type: psql:ONE_TO_MANY}
            }
        },
        [ORG_WORKFLOW_CONFIG]: {
            entityName: "OrgWorkflowConfig",
            tableName: "org_workflow_config",
            fieldMetadata: {
                id: {columnName: "id"},
                orgId: {columnName: "org_id"},
                assigneeRoles: {columnName: "assignee_roles"},
                assignees: {columnName: "assignees"},
                formatRequestData: {columnName: "format_request_data"},
                externalWorkflowEngineEndpoint: {columnName: "external_workflow_engine_endpoint"},
                workflowDefinitionId: {columnName: "workflow_definition_id"},
                "workflowdefinition.id": {relation: {entityName: "workflowdefinition", refField: "id"}},
                "workflowdefinition.name": {relation: {entityName: "workflowdefinition", refField: "name"}},
                "workflowdefinition.description": {relation: {entityName: "workflowdefinition", refField: "description"}},
                "workflowdefinition.approverTypes": {relation: {entityName: "workflowdefinition", refField: "approverTypes", refColumn: "approver_types"}},
                "workflowdefinition.executeUponApproval": {relation: {entityName: "workflowdefinition", refField: "executeUponApproval", refColumn: "execute_upon_approval"}},
                "workflowdefinition.allowParallelRequests": {relation: {entityName: "workflowdefinition", refField: "allowParallelRequests", refColumn: "allow_parallel_requests"}},
                "workflowdefinition.requestFormatSchema": {relation: {entityName: "workflowdefinition", refField: "requestFormatSchema", refColumn: "request_format_schema"}},
                "workflowinstances[].id": {relation: {entityName: "workflowinstances", refField: "id"}},
                "workflowinstances[].orgId": {relation: {entityName: "workflowinstances", refField: "orgId", refColumn: "org_id"}},
                "workflowinstances[].resource": {relation: {entityName: "workflowinstances", refField: "resource"}},
                "workflowinstances[].createdBy": {relation: {entityName: "workflowinstances", refField: "createdBy", refColumn: "created_by"}},
                "workflowinstances[].createdTime": {relation: {entityName: "workflowinstances", refField: "createdTime", refColumn: "created_time"}},
                "workflowinstances[].requestComment": {relation: {entityName: "workflowinstances", refField: "requestComment", refColumn: "request_comment"}},
                "workflowinstances[].data": {relation: {entityName: "workflowinstances", refField: "data"}},
                "workflowinstances[].status": {relation: {entityName: "workflowinstances", refField: "status"}},
                "workflowinstances[].reviewedBy": {relation: {entityName: "workflowinstances", refField: "reviewedBy", refColumn: "reviewed_by"}},
                "workflowinstances[].reviewerDecision": {relation: {entityName: "workflowinstances", refField: "reviewerDecision", refColumn: "reviewer_decision"}},
                "workflowinstances[].reviewComment": {relation: {entityName: "workflowinstances", refField: "reviewComment", refColumn: "review_comment"}},
                "workflowinstances[].reviewTime": {relation: {entityName: "workflowinstances", refField: "reviewTime", refColumn: "review_time"}},
                "workflowinstances[].orgWorkflowConfigId": {relation: {entityName: "workflowinstances", refField: "orgWorkflowConfigId", refColumn: "org_workflow_config_id"}},
                "workflowinstances[].workflowDefinitionId": {relation: {entityName: "workflowinstances", refField: "workflowDefinitionId"}}
            },
            keyFields: ["id"],
            joinMetadata: {
                workflowdefinition: {entity: WorkflowDefinition, fieldName: "workflowdefinition", refTable: "workflow_definition", refColumns: ["id"], joinColumns: ["workflow_definition_id"], 'type: psql:ONE_TO_MANY},
                workflowinstances: {entity: WorkflowInstance, fieldName: "workflowinstances", refTable: "workflow_instance", refColumns: ["org_workflow_config_id"], joinColumns: ["id"], 'type: psql:MANY_TO_ONE}
            }
        }
    };

    public isolated function init() returns persist:Error? {
        postgresql:Client|error dbClient = new (host = host, username = user, password = password, database = database, port = port, options = connectionOptions);
        if dbClient is error {
            return <persist:Error>error(dbClient.message());
        }
        self.dbClient = dbClient;
        self.persistClients = {
            [WORKFLOW_DEFINITION]: check new (dbClient, self.metadata.get(WORKFLOW_DEFINITION), psql:POSTGRESQL_SPECIFICS),
            [AUDIT_EVENT]: check new (dbClient, self.metadata.get(AUDIT_EVENT), psql:POSTGRESQL_SPECIFICS),
            [WORKFLOW_INSTANCE]: check new (dbClient, self.metadata.get(WORKFLOW_INSTANCE), psql:POSTGRESQL_SPECIFICS),
            [ORG_WORKFLOW_CONFIG]: check new (dbClient, self.metadata.get(ORG_WORKFLOW_CONFIG), psql:POSTGRESQL_SPECIFICS)
        };
    }

    isolated resource function get workflowdefinitions(WorkflowDefinitionTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get workflowdefinitions/[string id](WorkflowDefinitionTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post workflowdefinitions(WorkflowDefinitionInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(WORKFLOW_DEFINITION);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from WorkflowDefinitionInsert inserted in data
            select inserted.id;
    }

    isolated resource function put workflowdefinitions/[string id](WorkflowDefinitionUpdate value) returns WorkflowDefinition|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(WORKFLOW_DEFINITION);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/workflowdefinitions/[id].get();
    }

    isolated resource function delete workflowdefinitions/[string id]() returns WorkflowDefinition|persist:Error {
        WorkflowDefinition result = check self->/workflowdefinitions/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(WORKFLOW_DEFINITION);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get auditevents(AuditEventTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get auditevents/[string id](AuditEventTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post auditevents(AuditEventInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(AUDIT_EVENT);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from AuditEventInsert inserted in data
            select inserted.id;
    }

    isolated resource function put auditevents/[string id](AuditEventUpdate value) returns AuditEvent|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(AUDIT_EVENT);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/auditevents/[id].get();
    }

    isolated resource function delete auditevents/[string id]() returns AuditEvent|persist:Error {
        AuditEvent result = check self->/auditevents/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(AUDIT_EVENT);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get workflowinstances(WorkflowInstanceTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get workflowinstances/[string id](WorkflowInstanceTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post workflowinstances(WorkflowInstanceInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(WORKFLOW_INSTANCE);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from WorkflowInstanceInsert inserted in data
            select inserted.id;
    }

    isolated resource function put workflowinstances/[string id](WorkflowInstanceUpdate value) returns WorkflowInstance|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(WORKFLOW_INSTANCE);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/workflowinstances/[id].get();
    }

    isolated resource function delete workflowinstances/[string id]() returns WorkflowInstance|persist:Error {
        WorkflowInstance result = check self->/workflowinstances/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(WORKFLOW_INSTANCE);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    isolated resource function get orgworkflowconfigs(OrgWorkflowConfigTargetType targetType = <>, sql:ParameterizedQuery whereClause = ``, sql:ParameterizedQuery orderByClause = ``, sql:ParameterizedQuery limitClause = ``, sql:ParameterizedQuery groupByClause = ``) returns stream<targetType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "query"
    } external;

    isolated resource function get orgworkflowconfigs/[string id](OrgWorkflowConfigTargetType targetType = <>) returns targetType|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor",
        name: "queryOne"
    } external;

    isolated resource function post orgworkflowconfigs(OrgWorkflowConfigInsert[] data) returns string[]|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORG_WORKFLOW_CONFIG);
        }
        _ = check sqlClient.runBatchInsertQuery(data);
        return from OrgWorkflowConfigInsert inserted in data
            select inserted.id;
    }

    isolated resource function put orgworkflowconfigs/[string id](OrgWorkflowConfigUpdate value) returns OrgWorkflowConfig|persist:Error {
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORG_WORKFLOW_CONFIG);
        }
        _ = check sqlClient.runUpdateQuery(id, value);
        return self->/orgworkflowconfigs/[id].get();
    }

    isolated resource function delete orgworkflowconfigs/[string id]() returns OrgWorkflowConfig|persist:Error {
        OrgWorkflowConfig result = check self->/orgworkflowconfigs/[id].get();
        psql:SQLClient sqlClient;
        lock {
            sqlClient = self.persistClients.get(ORG_WORKFLOW_CONFIG);
        }
        _ = check sqlClient.runDeleteQuery(id);
        return result;
    }

    remote isolated function queryNativeSQL(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>) returns stream<rowType, persist:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor"
    } external;

    remote isolated function executeNativeSQL(sql:ParameterizedQuery sqlQuery) returns psql:ExecutionResult|persist:Error = @java:Method {
        'class: "io.ballerina.stdlib.persist.sql.datastore.PostgreSQLProcessor"
    } external;

    public isolated function close() returns persist:Error? {
        error? result = self.dbClient.close();
        if result is error {
            return <persist:Error>error(result.message());
        }
        return result;
    }
}

