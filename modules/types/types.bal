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
import ballerina/time;

//import ballerina/time;

# Workflow definition for an action. This defines the behavior of the workflow
#
# + id - identifier of the workflow
# + name - name of the workflow
# + description - description of the workflow
# + approverTypes - list of approver types supported by the workflow
# + executeUponApproval - flag to indicate whether the action should be executed upon approval
# + allowParallelRequests - flag to indicate whether parallel requests are allowed. For conflicting actions,
# only one request can present in the org at a time
# + requestFormatSchema - schema to format the input data for the approval
public type WorkflowDefinition record {|
    * WorkflowDefinitionIdentifier;
    ApproverType[] approverTypes;
    boolean executeUponApproval;
    boolean allowParallelRequests;
    //Resource and action should come here?
    map<FormatSchemaEntry> requestFormatSchema;
|};

public type WorkflowDefinitionIdentifier record {|
    string id;
    string name;
    string description;
|};

# Request to configure a workflow definition for an organization.
#
# + workflowDefinitionId - identifier of the workflow definition against which configuration is done
# + assigneeRoles - list of roles to assign the action
# + assignees - list of users to assign the action (user ids)
# + formatRequestData - flag to indicate whether the input data should be formatted before sending for approval
# based on the schema defined in the workflow definition. If false, the input data will be
# sent as it is.
# + externalWorkflowEngineEndpoint - endpoint of the external workflow engine to execute the workflow
public type OrgWorkflowConfigRequest record {|
    string workflowDefinitionId;
    string[] assigneeRoles;
    string[] assignees;
    boolean formatRequestData = true;
    string externalWorkflowEngineEndpoint?;
|};

# Organizational configuration of a workflow definition.
# A workflow instance is created within the org based on this configuration.
#
# + id - Identifier of the workflow configuration
# + orgId - field description
public type OrgWorkflowConfig record {|
    string id;
    string orgId;
    * OrgWorkflowConfigRequest;
|};

public type WorkflowInstanceResponse record {|
    string wkfId; // for a given action and resource, this is unique for a given org
    string orgId;
    time:Utc createdTime;
    string createdBy;
    *WorkflowInstanceCreateRequest;
    never data?; //We get data separately
    WorkflowDefinitionIdentifier workflowDefinitionIdentifier;
    ReviewerDecisionRequest reviewerDecision?;
    WorkflowMgtStatus status = PENDING;
|};

public type WorkflowInstance record {|
    string id; // for a given action and resource, this is unique for a given org
    string orgId;
    time:Utc createdTime;
    string createdBy;
    *WorkflowInstanceCreateRequest;
    never data?; //We get data separately
    string orgWorkflowConfigId;
    ReviewerDecisionRequest reviewerDecision?;
    WorkflowMgtStatus status = PENDING;
|};


# Request to create a workflow instance
#
# + context - context of the workflow. This is used to identify the workflow instance uniquely within the org
# + requestComment - field description
# + data - field description
public type WorkflowInstanceCreateRequest record {|
    WorkflowContext context;
    string requestComment?;
    json data;
|};

public type ReviewerDecisionRequest record {|
    string reviewedBy?; // get by JWT
    ReviewerDecision decision;
    string reviewComment?;
|};

public type AuditEventRequest record {|
    string orgId;
    time:Utc timestamp;
    AuditEventType eventType;
    string user;
    string 'resource;
    string workflowInstanceId;
    string comment?;
    string workflowDefinitionId;
|};

public type AuditEvent record {|
    string id;
    *AuditEventRequest;
    never workflowDefinitionId?;
    record {|
        string id;
        string name;
        string description;
    |} workflowDefinition;
|};

# Schema instruction on how to format input data field to form
# data for the workflow
#
# + displayName - display name of the field
# + dataType - data type of the field
# + extractfrom - json path to extract the field from the input data
public type FormatSchemaEntry record {|
    string displayName;
    string dataType;
    string extractfrom;
|};

public type WorkflowInstanceCreateNotification record {|
    string id;
    *WorkflowInstanceCreateRequest;
|};

# Context of the workflow. This is used to identify the workflow instance uniquely within the org.
#
# + workflowDefinitionIdentifier - Identifier of the workflow definition. (one of the workflow definitions predefined in the system)
# + 'resource - Unique identifier of the resource attached to the approval request (e.g. component id, build id)
public type WorkflowContext record {|
    string workflowDefinitionIdentifier;
    string 'resource;
|};

public type ReviewerDecision APPROVED|REJECTED;

# Status of a workflow definition (Choreo operation) within the org
public enum WorkflowMgtStatus {
    DISABLED,
    PENDING,
    APPROVED,
    REJECTED,
    NOT_FOUND,
    TIMEOUT,
    CANCELLED
};

public enum ApproverType {
    ROLE,
    USER
};

public enum AuditEventType {
    REQUEST,
    APPROVE,
    REJECT,
    EXECUTE,
    CANCEL
};
