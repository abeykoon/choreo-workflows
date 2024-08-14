-- Create workflow_definition table
CREATE TABLE workflow_definition (
    id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    approver_types VARCHAR(255) NOT NULL,
    execute_upon_approval BOOLEAN NOT NULL,
    allow_parallel_requests BOOLEAN NOT NULL,
    request_format_schema TEXT NOT NULL
);

-- Create org_workflow_config table
CREATE TABLE org_workflow_config (
    id VARCHAR(255) PRIMARY KEY,
    org_id VARCHAR(255) NOT NULL,
    workflow_definition_id VARCHAR(255) NOT NULL REFERENCES workflow_definition(id),
    assignee_roles VARCHAR(255) NOT NULL,
    assignees VARCHAR(255) NOT NULL,
    format_request_data BOOLEAN NOT NULL,
    external_workflow_engine_endpoint VARCHAR(255)
);

-- Create workflow_instance table
CREATE TABLE workflow_instance (
    id VARCHAR(255) PRIMARY KEY,
    org_workflow_config_id VARCHAR(255) NOT NULL REFERENCES org_workflow_config(id),
    org_id VARCHAR(255) NOT NULL,
    resource VARCHAR(255) NOT NULL,
    action VARCHAR(255) NOT NULL,
    created_by VARCHAR(255) NOT NULL,
    created_time TIMESTAMPTZ NOT NULL,
    request_comment TEXT,
    data TEXT NOT NULL,
    status VARCHAR(50) NOT NULL,
    reviewed_by VARCHAR(255),
    reviewer_decision VARCHAR(50),
    review_comment TEXT,
    review_time TIMESTAMPTZ
);

-- Create audit_event table
CREATE TABLE audit_event (
    id VARCHAR(255) PRIMARY KEY,
    org_id VARCHAR(255) NOT NULL,
    event_type VARCHAR(50) NOT NULL, -- e.g., request, review, approve, reject, cancel, execute
    timestamp TIMESTAMPTZ NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    action VARCHAR(255) NOT NULL,
    resource VARCHAR(255) NOT NULL,
    workflow_instance_id VARCHAR(255),
    comment TEXT
);

-- Indexes for better performance on JSONB fields (optional but recommended)
--CREATE INDEX idx_workflow_definition_request_format_schema ON workflow_definition USING GIN (request_format_schema);
--CREATE INDEX idx_workflow_instance_data ON workflow_instance USING GIN (data);
