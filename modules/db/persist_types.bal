// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/time;

public type WorkflowDefinition record {|
    readonly string id;
    string name;
    string? description;
    string approverTypes;
    boolean executeUponApproval;
    boolean allowParallelRequests;
    string requestFormatSchema;

|};

public type WorkflowDefinitionOptionalized record {|
    string id?;
    string name?;
    string? description?;
    string approverTypes?;
    boolean executeUponApproval?;
    boolean allowParallelRequests?;
    string requestFormatSchema?;
|};

public type WorkflowDefinitionWithRelations record {|
    *WorkflowDefinitionOptionalized;
    OrgWorkflowConfigOptionalized[] orgworkflowconfigs?;
    WorkflowInstanceOptionalized[] workflowinstance?;
|};

public type WorkflowDefinitionTargetType typedesc<WorkflowDefinitionWithRelations>;

public type WorkflowDefinitionInsert WorkflowDefinition;

public type WorkflowDefinitionUpdate record {|
    string name?;
    string? description?;
    string approverTypes?;
    boolean executeUponApproval?;
    boolean allowParallelRequests?;
    string requestFormatSchema?;
|};

public type AuditEvent record {|
    readonly string id;
    string orgId;
    string eventType;
    time:Utc timestamp;
    string userId;
    string workflowDefinitionId;
    string 'resource;
    string workflowInstanceId;
    string? comment;
|};

public type AuditEventOptionalized record {|
    string id?;
    string orgId?;
    string eventType?;
    time:Utc timestamp?;
    string userId?;
    string workflowDefinitionId?;
    string 'resource?;
    string? workflowInstanceId?;
    string? comment?;
|};

public type AuditEventTargetType typedesc<AuditEventOptionalized>;

public type AuditEventInsert AuditEvent;

public type AuditEventUpdate record {|
    string orgId?;
    string eventType?;
    time:Utc timestamp?;
    string userId?;
    string workflowDefinitionId?;
    string 'resource?;
    string? workflowInstanceId?;
    string? comment?;
|};

public type WorkflowInstance record {|
    readonly string id;
    string orgId;
    string 'resource;
    string createdBy;
    time:Utc createdTime;
    string? requestComment;
    string data;
    string status;
    string? reviewedBy;
    string? reviewerDecision;
    string? reviewComment;
    time:Utc? reviewTime;
    string orgWorkflowConfigId;
    string workflowDefinitionId;
|};

public type WorkflowInstanceOptionalized record {|
    string id?;
    string orgId?;
    string 'resource?;
    string createdBy?;
    time:Utc createdTime?;
    string? requestComment?;
    string data?;
    string status?;
    string? reviewedBy?;
    string? reviewerDecision?;
    string? reviewComment?;
    time:Utc? reviewTime?;
    string orgWorkflowConfigId?;
    string workflowDefinitionId?;
|};

public type WorkflowInstanceWithRelations record {|
    *WorkflowInstanceOptionalized;
    OrgWorkflowConfigOptionalized orgworkflowconfig?;
    WorkflowDefinitionOptionalized workflowDefinition?;
|};

public type WorkflowInstanceTargetType typedesc<WorkflowInstanceWithRelations>;

public type WorkflowInstanceInsert WorkflowInstance;

public type WorkflowInstanceUpdate record {|
    string orgId?;
    string 'resource?;
    string createdBy?;
    time:Utc createdTime?;
    string? requestComment?;
    string data?;
    string status?;
    string? reviewedBy?;
    string? reviewerDecision?;
    string? reviewComment?;
    time:Utc? reviewTime?;
    string orgWorkflowConfigId?;
    string workflowDefinitionId?;
|};

public type OrgWorkflowConfig record {|
    readonly string id;
    string orgId;
    string assigneeRoles;
    string assignees;
    boolean formatRequestData;
    string? externalWorkflowEngineEndpoint;
    string workflowDefinitionId;

|};

public type OrgWorkflowConfigOptionalized record {|
    string id?;
    string orgId?;
    string assigneeRoles?;
    string assignees?;
    boolean formatRequestData?;
    string? externalWorkflowEngineEndpoint?;
    string workflowDefinitionId?;
|};

public type OrgWorkflowConfigWithRelations record {|
    *OrgWorkflowConfigOptionalized;
    WorkflowDefinitionOptionalized workflowdefinition?;
    WorkflowInstanceOptionalized[] workflowinstances?;
|};

public type OrgWorkflowConfigTargetType typedesc<OrgWorkflowConfigWithRelations>;

public type OrgWorkflowConfigInsert OrgWorkflowConfig;

public type OrgWorkflowConfigUpdate record {|
    string orgId?;
    string assigneeRoles?;
    string assignees?;
    boolean formatRequestData?;
    string? externalWorkflowEngineEndpoint?;
    string workflowDefinitionId?;
|};
