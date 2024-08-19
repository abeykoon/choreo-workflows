import ballerina/persist as _;
import ballerina/time;
import ballerinax/persist.sql;

@sql:Name {value: "workflow_definition"}
public type WorkflowDefinition record {|
    @sql:Varchar {length: 255}
    readonly string id;
    @sql:Varchar {length: 255}
    string name;
    string? description;
    @sql:Name {value: "approver_types"}
    @sql:Varchar {length: 255}
    string approverTypes;
    @sql:Name {value: "execute_upon_approval"}
    boolean executeUponApproval;
    @sql:Name {value: "allow_parallel_requests"}
    boolean allowParallelRequests;
    @sql:Name {value: "request_format_schema"}
    string requestFormatSchema;
    OrgWorkflowConfig[] orgworkflowconfigs;
	WorkflowInstance[] workflowinstance;
|};

@sql:Name {value: "audit_event"}
public type AuditEvent record {|
    @sql:Varchar {length: 255}
    readonly string id;
    @sql:Name {value: "org_id"}
    @sql:Varchar {length: 255}
    string orgId;
    @sql:Name {value: "event_type"}
    @sql:Varchar {length: 50}
    string eventType;
    time:Utc timestamp;
    @sql:Name {value: "user_id"}
    @sql:Varchar {length: 255}
    string userId;
    @sql:Name {value: "workflow_definition_id"}
    @sql:Varchar {length: 255}
    string workflowDefinitionId;
    @sql:Varchar {length: 255}
    string 'resource;
    @sql:Name {value: "workflow_instance_id"}
    @sql:Varchar {length: 255}
    string workflowInstanceId;
    string? comment;
|};

@sql:Name {value: "workflow_instance"}
public type WorkflowInstance record {|
    @sql:Varchar {length: 255}
    readonly string id;
    @sql:Name {value: "org_workflow_config_id"}
    @sql:Varchar {length: 255}
    string orgWorkflowConfigId;
    @sql:Name {value: "org_id"}
    @sql:Varchar {length: 255}
    string orgId;
    @sql:Varchar {length: 255}
    string 'resource;
    @sql:Name {value: "workflow_definition_id"}
    @sql:Varchar {length: 255}
    string workflowDefinitionId;
    @sql:Name {value: "created_by"}
    @sql:Varchar {length: 255}
    string createdBy;
    @sql:Name {value: "created_time"}
    time:Utc createdTime;
    @sql:Name {value: "request_comment"}
    string? requestComment;
    string data;
    @sql:Varchar {length: 50}
    string status;
    @sql:Name {value: "reviewed_by"}
    @sql:Varchar {length: 255}
    string? reviewedBy;
    @sql:Name {value: "reviewer_decision"}
    @sql:Varchar {length: 50}
    string? reviewerDecision;
    @sql:Name {value: "review_comment"}
    string? reviewComment;
    @sql:Name {value: "review_time"}
    time:Utc? reviewTime;
    @sql:Relation {keys: ["orgWorkflowConfigId"]}
    OrgWorkflowConfig orgworkflowconfig;
    @sql:Relation {keys: ["workflowDefinitionId"]}
    WorkflowDefinition workflowDefinition;
|};

@sql:Name {value: "org_workflow_config"}
public type OrgWorkflowConfig record {|
    @sql:Varchar {length: 255}
    readonly string id;
    @sql:Name {value: "org_id"}
    @sql:Varchar {length: 255}
    string orgId;
    @sql:Name {value: "workflow_definition_id"}
    @sql:Varchar {length: 255}
    string workflowDefinitionId;
    @sql:Name {value: "assignee_roles"}
    @sql:Varchar {length: 255}
    string assigneeRoles;
    @sql:Varchar {length: 255}
    string assignees;
    @sql:Name {value: "format_request_data"}
    boolean formatRequestData;
    @sql:Name {value: "external_workflow_engine_endpoint"}
    @sql:Varchar {length: 255}
    string? externalWorkflowEngineEndpoint;
    @sql:Relation {keys: ["workflowDefinitionId"]}
    WorkflowDefinition workflowdefinition;
    WorkflowInstance[] workflowinstances;
|};
