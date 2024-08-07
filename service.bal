import workflow_mgt_service.config;
import ballerina/http;

//util:BadRequest|util:InternalServerError|util:Forbidden

listener http:Listener httpListener = new (config:servicePort, config = {
    requestLimits: {
        maxUriLength: 4096,
        maxHeaderSize: 64000, // inceased header size to support JWT tokens
        maxEntityBodySize: -1
    }
});

service http:Service /workflows on httpListener {

    # Get all the workflow definitions defined in Choreo.
    #
    # + ctx - request context
    # + return - list of workflow definitions
    resource function get definitions(http:RequestContext ctx) returns WorkflowDefinition[] {
        return [];
    }

    # Configure a workflow for the organization.
    #
    # + workflow\-definition\-id - identifier of the workflow definition to configure
    # + ctx - request context
    resource function post definitions/[string workflow\-definition\-id]/config (http:RequestContext ctx,
            WorkflowConfig workflowConfig) returns Workflow {
        //validate orgId from the context
        return {};
    }

    # Get all the workflow configurations defined in the organization.
    #
    # + ctx - Request context
    # + return - List of workflow configurations
    resource function get definitions/config (http:RequestContext ctx) returns WorkflowConfig[] {
        return {};
    }


    # Get filtered workflows active in the organization.
    #
    # + ctx - Request context
    # + 'limit - Maximum number of workflows to return
    # + offset - Offset to start returning workflows
    # + action - Action to filter the workflows
    # + status - Status to filter the workflows
    # + 'resource - Resource to filter the workflows
    # + requested\-by - Requested user to filter the workflows
    # + return - List of workflows
    resource function get \ (
        http:RequestContext ctx,
        int 'limit = 20,
        int offset = 0,
        string? action = (),
        string? status = (),
        string? 'resource = (),
        string? requested\-by = ()
    ) returns Workflow[] {

        //default sorting is by requested time
        //Get orgId from the context

        //if viewed by a manager, show workflows assigned to the manager
        //if viewed by a user, show workflows requested by the user
        //if viewed by an admin, show all workflows

        return [];
    }

    # Get a specific workflow instance.
    #
    # + workflow\-id - Identifier of the workflow instance
    # + ctx - Request context
    # + return - Workflow instance
    resource function get [string workflow\-id] (http:RequestContext ctx) returns Workflow {
        return {};
    }

    # Creates a new workflow request.
    #
    # + ctx - Request context
    # + request - Workflow request
    # + return - Created workflow instance
    resource function post \ (http:RequestContext ctx, WorkflowRequest request) returns Workflow {
        return {};
    }

    # Cancel a workflow request.
    #
    # + workflow\-id - Identifier of the workflow instance
    # + ctx - Request context
    # + return - Cancelled workflow instance
    resource function delete [string workflow\-id] (http:RequestContext ctx) returns Workflow {
        //remove from workflow DB
        return {};
    }

    # Review a workflow request.
    #
    # + workflow\-id - Identifier of the workflow instance
    # + ctx - Request context
    # + review - Payload with review details
    # + return - Updated workflow instance
    resource function post [string workflow\-id]/review (http:RequestContext ctx, Review review) returns Workflow {
        //check approver is not the same as the requestedBy
        //update status
        //notify or execute the action (should by async? what if errored out? ressiency?)
        return {};
    }

    resource function post [string workflow\-id]/add\-new\-reviewer (http:RequestContext ctx, string reviewer) returns Workflow {
        //check approver is not the same as the requestedBy
        return {};

    }

    resource function get status(http:RequestContext ctx, string action, string 'resource) returns WorkflowStatus {     //frontend needs this

        //validate action first
        return DISABLED;
    }

    resource function get data(http:RequestContext ctx, string action, string 'resource) returns json {     //component BE needs this

        //format the captured data from the workflow request for
        //the UI/notifications looking at workflow definition and return
        return {};
    }

    resource function get audits(
            http:RequestContext ctx,
            string orgId,
            int 'limit = 20,
            int offset = 0,
            string? action = (),
            string? status = (),
            string? 'resource = (),
            string? requested\-by = (),
            string? reviwed\-by = (),
            string? executed\-by = ()
    ) returns WorkflowAudit[] { //default sorting is by requested time
        return [];
    }

}
