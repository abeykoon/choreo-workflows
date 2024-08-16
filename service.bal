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

import workflow_mgt_service.config;
import workflow_mgt_service.util;
import ballerina/http;
import workflow_mgt_service.types;
import workflow_mgt_service.db;
import workflow_mgt_service.'error as err;

listener http:Listener httpListener = new (config:servicePort, config = {
    requestLimits: {
        maxUriLength: 4096,
        maxHeaderSize: 64000, // inceased header size to support JWT tokens
        maxEntityBodySize: -1
    }
});

util:InternalServerError internalError = {body: {'error: "Not implemented", details: "This feature is not implemented yet."}};

service http:Service /workflow\-mgt/v1 on httpListener {

    # Get all the workflow definitions defined in Choreo.
    #
    # + ctx - request context
    # + return - list of workflow definitions
    resource function get workflow/definitions(http:RequestContext ctx) returns types:WorkflowDefinition[]|
    util:InternalServerError|util:Forbidden {
        util:Context context = util:getContext(ctx);
        do {
                return check db:getWorkflowDefinitions(context);
        } on fail error e {
            util:logError(context, "Error occurred while getting workflow definitions", e);
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while retrieving workflow definitions"
                }
            };
            return httpErr;
        }
    }

    # Get all the workflow configurations defined in the organization.
    #
    # + ctx - Request context
    # + return - List of workflow configurations
    resource function get workflow/configs(http:RequestContext ctx) returns types:OrgWorkflowConfig[]
        |util:InternalServerError|util:Forbidden {
        util:Context context = util:getContext(ctx);
        do {
            return check db:getWorkflowConfigsForOrg(context);
        } on fail error e {
            util:logError(context, "Error occurred while getting workflow configurations", e);
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while retrieving workflow configurations"
                }
            };
            return httpErr;
        }
    }

    # Configure a workflow for the organization.
    #
    # + ctx - request context
    # + workflowConfigRequest - parameter description
    # + return - configured workflow
    resource function post workflow/configs(http:RequestContext ctx, types:OrgWorkflowConfigRequest workflowConfigRequest) returns types:OrgWorkflowConfig
            |util:BadRequest|util:InternalServerError|util:Forbidden {
        util:Context context = util:getContext(ctx);
        do {
            return check db:persistWorkflowConfig(context, workflowConfigRequest);
        } on fail error e {
            util:logError(context, "Error occurred while configuring workflow", e);
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while configuring workflow"
                }
            };
            //TODO: check for validation errors
            return httpErr;
        }
    }

    # Update a workflow configuration.
    #
    # + workflow\-config\-id - identifier of the workflow configuration
    # + ctx - request context
    # + workflowConfig - Updated workflow configuration
    # + return - Configured workflow
    resource function put workflow/configs/[string workflow\-config\-id](http:RequestContext ctx, types:OrgWorkflowConfigRequest workflowConfig) returns types:OrgWorkflowConfig|util:BadRequest|util:InternalServerError|util:Forbidden {
        util:Context context = util:getContext(ctx);
        do {
            types:OrgWorkflowConfig workflowConfigToUpdate = check db:getWorkflowConfigById(context, workflow\-config\-id);
            if !check ensureWkfConfigBelongsToCorrectOrg(context, workflowConfigToUpdate) {
                string errorMsg = string `workflow configuration with id ${workflow\-config\-id} does not belong to the organization`;
                check error err:AuthenticationError(errorMsg);
            }
            return check db:updateWorkflowConfigById(context, workflow\-config\-id, workflowConfig);
        } on fail error e {
            util:logError(context, "Error occurred while updating workflow configuration", e);
            if e is err:AuthenticationError {
                util:Forbidden httpErr = {
                    body: {
                        "error": "Forbidden",
                        "details": e.message()
                    }
                };
                return httpErr;
            }
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while updating workflow configuration"
                }
            };
            return httpErr;
        }
    }



    # Delete a workflow configuration.
    #
    # + workflow\-config\-id - Identifier of the workflow configuration
    # + ctx - Request context
    # + return - Deleted workflow configuration
    resource function delete workflow/configs/[string workflow\-config\-id](http:RequestContext ctx) returns types:OrgWorkflowConfig
            |util:InternalServerError|util:Forbidden|util:ResourceNotFound {
        util:Context context = util:getContext(ctx);
        do {
            types:OrgWorkflowConfig workflowConfigToDelete = check db:getWorkflowConfigById(context, workflow\-config\-id);
            if !check ensureWkfConfigBelongsToCorrectOrg(context, workflowConfigToDelete) {
                string errorMsg = string `workflow configuration with id ${workflow\-config\-id} does not belong to the organization`;
                check error err:AuthenticationError(errorMsg);
            }
            return check db:deleteWorkflowConfigById(context, workflow\-config\-id);
        } on fail error e {
            util:logError(context, "Error occurred while deleting workflow configuration", e);
            if e is err:AuthenticationError {
                util:Forbidden httpErr = {
                    body: {
                        "error": "Forbidden",
                        "details": e.message()
                    }
                };
                return httpErr;
            }
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while deleting workflow configuration"
                }
            };
            return httpErr;
        }
    }

    # Get filtered workflows active in the organization.
    #
    # + ctx - Request context
    # + 'limit - Maximum number of workflows to return
    # + offset - Offset to start returning workflows
    # + action - Action to filter the workflows
    # + status - Status to filter the workflows
    # + 'resource - Resource to filter the workflows
    # + created\-by - User who created the workflows to filter the workflows
    # + return - List of workflows
    resource function get workflow\-instances(
            http:RequestContext ctx,
            int 'limit = 20,
            int offset = 0,
            string? wkfDefinitionId = (),
            string? status = (),
            string? 'resource = (),
            string? created\-by = ()
    ) returns types:WorkflowInstanceResponse[]|util:InternalServerError|util:Forbidden|util:BadRequest {
        util:Context context = util:getContext(ctx);
        do {
            return check getWorkflowInstances(context, 'limit, offset, wkfDefinitionId, status, 'resource, created\-by);
        } on fail error e {
            util:logError(context, "Error occurred while getting workflow instances", e);
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while retrieving workflow instances"
                }
            };
            return httpErr;
        }
    }

    # Get a specific workflow instance.
    #
    # + workflow\-instance\-id - Identifier of the workflow instance
    # + ctx - Request context
    # + return - Workflow instance
    resource function get workflow\-instances/[string workflow\-instance\-id](http:RequestContext ctx) returns types:WorkflowInstanceResponse
            |util:InternalServerError|util:Forbidden|util:BadRequest|util:ResourceNotFound {
        util:Context context = util:getContext(ctx);
        do {
            types:WorkflowInstanceResponse wkfInstance = check db:getWorkflowInstanceResponseById(context, workflow\-instance\-id);
            if !check ensureWkfInstanceBelongsToCorrectOrg(context, wkfInstance) {
                string errorMsg = string `workflow instance with id ${workflow\-instance\-id} does not belong to the organization`;
                check error err:AuthenticationError(errorMsg);
            }
        } on fail error e {
            util:logError(context, "Error occurred while getting workflow instance", e);
            if e is err:ResourceNotFoundError {
                util:ResourceNotFound httpErr = {
                    body: {
                        "error": "Resource Not Found",
                        "details": string `Workflow instance with id ${workflow\-instance\-id} not found`
                    }
                };
                return httpErr;
            }
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while retrieving workflow instance"
                }
            };
            return httpErr;
        }
    }

    # Creates a new workflow request.
    #
    # + ctx - Request context
    # + request - Workflow request
    # + return - Identifier of the created workflow instance
    resource function post workflow\-instances(http:RequestContext ctx, types:WorkflowInstanceCreateRequest request) returns string
            |util:BadRequest|util:InternalServerError|util:Forbidden {
        util:Context context = util:getContext(ctx);
        do {
            return check db:persistWorkflowInstance(context, request);
        } on fail error e {
            util:logError(context, "Error occurred while creating workflow instance", e);
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while creating workflow instance"
                }
            };
            return httpErr;
        }
    }

    # Cancel a workflow request.
    #
    # + workflow\-instance\-id - Identifier of the workflow instance
    # + ctx - Request context
    # + return - Cancelled workflow instance
    resource function delete workflow\-instances/[string workflow\-instance\-id](http:RequestContext ctx) returns string
            |util:InternalServerError|util:Forbidden|util:ResourceNotFound {
        util:Context context = util:getContext(ctx);
        do {
            types:WorkflowInstanceResponse wkfInstance = check db:getWorkflowInstanceResponseById(context, workflow\-instance\-id);
            if !check ensureWkfInstanceBelongsToCorrectOrg(context, wkfInstance) {
                string errorMsg = string `workflow instance with id ${workflow\-instance\-id} does not belong to the organization`;
                check error err:AuthenticationError(errorMsg);
            }
            return check db:deleteWorkflowInstance(context, workflow\-instance\-id);
        } on fail error e {
            util:logError(context, "Error occurred while deleting workflow instance", e);
            if e is err:ResourceNotFoundError {
                util:ResourceNotFound httpErr = {
                    body: {
                        "error": "Resource Not Found",
                        "details": string `Workflow instance with id ${workflow\-instance\-id} not found`
                    }
                };
                return httpErr;
            }
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while deleting workflow instance"
                }
            };
            return httpErr;
        }
    }

    # Get the status of workflows related to a given Choreo operation and a resource.
    # This is used to check if a request is in progress for a conflicting action.
    #
    # + ctx - Request context
    # + wkfDefinitionId - Id of the workflow definition associated with the Choreo operation
    # + 'resource - Resource on which the action is performed
    # + return - Status of the workflows
    resource function get workflow\-instances/status(http:RequestContext ctx, string wkfDefinitionId, string 'resource) returns types:WorkflowMgtStatus
            |util:InternalServerError|util:Forbidden {
        util:Context context = util:getContext(ctx);
        do {
            return check getWorkflowStatus(ctx, wkfDefinitionId, 'resource);
        } on fail error e {
            util:logError(context, string `Error occurred while getting workflow status for Choreo operation ${wkfDefinitionId}`, e);
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while getting workflow status"
                }
            };
            return httpErr;
        }
    }

    # Review a workflow request.
    #
    # + workflow\-instance\-id - Identifier of the workflow instance
    # + ctx - Request context
    # + review - Payload with review details
    # + return - Updated workflow instance
    resource function post review/[string workflow\-instance\-id]/decision(http:RequestContext ctx, types:ReviewerDecisionRequest review) returns string
            |util:BadRequest|util:InternalServerError|util:Forbidden|util:ResourceNotFound {
        //TODO: check approver is not the same as the requestedBy
        //update status in DB
        //TODO: notify or execute the action (should by async? what if errored out? ressiency?)
        util:Context context = util:getContext(ctx);
        do {
            types:WorkflowInstanceResponse wkfInstance = check db:getWorkflowInstanceResponseById(context, workflow\-instance\-id);
            if !check ensureWkfInstanceBelongsToCorrectOrg(context, wkfInstance) {
                string errorMsg = string `workflow instance with id ${workflow\-instance\-id} does not belong to the organization`;
                check error err:AuthenticationError(errorMsg);
            }
            return check db:updateWorkflowInstanceWithReviewerDecision(context, workflow\-instance\-id, review);
        } on fail error e {
            util:logError(context, string`Error occurred while reviewing workflow instance with id ${workflow\-instance\-id}`, e);
            if e is err:ResourceNotFoundError {
                util:ResourceNotFound httpErr = {
                    body: {
                        "error": "Resource Not Found",
                        "details": string `Workflow instance with id ${workflow\-instance\-id} not found`
                    }
                };
                return httpErr;
            }
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while processing and persisting review for workflow instance"
                }
            };
            return httpErr;
        }
    }

    # Get the formatted review data captured at the workflow request.
    # This is used to display the captured data in UI/email/notifications.
    # The format is performed based on the workflow definition.
    #
    # + workflow\-instance\-id - Identifier of the workflow instance
    # + ctx - Request context
    # + return - Formatted review data
    resource function get review/[string workflow\-instance\-id]/data(http:RequestContext ctx) returns json
            |util:InternalServerError|util:Forbidden|util:ResourceNotFound {
        //component BE needs this
        //format the captured data from the workflow request for
        //the UI/notifications looking at workflow definition and return
        util:Context context = util:getContext(ctx);
        do {
            types:WorkflowInstanceResponse wkfInstance = check db:getWorkflowInstanceResponseById(context, workflow\-instance\-id);
            if !check ensureWkfInstanceBelongsToCorrectOrg(context, wkfInstance) {
                string errorMsg = string `workflow instance with id ${workflow\-instance\-id} does not belong to the organization`;
                check error err:AuthenticationError(errorMsg);
            }
            json data = check db:getWorkflowInstanceData(context, workflow\-instance\-id);
            return check formatDataForReviewer(workflow\-instance\-id, wkfInstance.data);
        } on fail error e {
            util:logError(context, string `Error occurred while getting review data for workflow instance with id ${workflow\-instance\-id}`, e);
            if e is err:ResourceNotFoundError {
                util:ResourceNotFound httpErr = {
                    body: {
                        "error": "Resource Not Found",
                        "details": string `Workflow instance with id ${workflow\-instance\-id} not found`
                    }
                };
                return httpErr;
            }
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while formatting review data for workflow instance"
                }
            };
            return httpErr;
        }
    }

    # Get all the audits of the workflows in the organization based on the filters.
    #
    # + ctx - Request context
    # + orgId - Organization ID
    # + 'limit - Maximum number of audits to return
    # + offset - Offset to start returning audits
    # + action - Action to filter the audits
    # + status - Status to filter the audits
    # + 'resource - Resource to filter the audits
    # + requested\-by - Requested user to filter the audits
    # + reviwed\-by - Reviewer to filter the audits
    # + executed\-by - Executor of the action after approval to filter the audits
    # + return - List of audit records
    resource function get audits(
            http:RequestContext ctx,
            string orgId,
            int 'limit = 20,
            int offset = 0,
            string? wkfDefinitionId = (),
            string? status = (),
            string? 'resource = (),
            types:AuditEventType? event\-type = (),
            string? user\-id = (),
    ) returns types:AuditEvent[]|util:InternalServerError|util:Forbidden|util:BadRequest {
        //default sorting is by requested time
        util:Context context = util:getContext(ctx);
        do {
            return check db:searchAuditEvents(context, 'limit, offset, wkfDefinitionId, status, 'resource, event\-type.toString(), user\-id);
        } on fail error e {
            util:logError(context, "Error occurred while getting audits", e);
            if e is err:ResourceNotFoundError {
                return [];
            }
            util:InternalServerError httpErr = {
                body: {
                    "error": "Internal Server Error",
                    "details": "Error while retrieving audits"
                }
            };
            return httpErr;
        }
    }

    # Get all the audits of a specific workflow run.
    #
    # + workflow\-instance\-id - Identifier of the workflow instance
    # + ctx - Request context
    # + return - List of audits related to the workflow run
    resource function get audits/[string workflow\-instance\-id](http:RequestContext ctx) returns types:AuditEvent[]
            |util:InternalServerError|util:Forbidden|util:BadRequest {
       //implement this
    }

}
