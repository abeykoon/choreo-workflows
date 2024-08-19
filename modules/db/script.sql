-- AUTO-GENERATED FILE.

-- This file is an auto-generated file by Ballerina persistence layer for model.
-- Please verify the generated scripts and execute them against the target DB server.

DROP TABLE IF EXISTS "workflow_instance";
DROP TABLE IF EXISTS "org_workflow_config";
DROP TABLE IF EXISTS "audit_event";
DROP TABLE IF EXISTS "workflow_definition";

CREATE TABLE "workflow_definition" (
	"id" VARCHAR(255) NOT NULL,
	"name" VARCHAR(255) NOT NULL,
	"description" VARCHAR(191),
	"approver_types" VARCHAR(255) NOT NULL,
	"execute_upon_approval" BOOLEAN NOT NULL,
	"allow_parallel_requests" BOOLEAN NOT NULL,
	"request_format_schema" VARCHAR(191) NOT NULL,
	PRIMARY KEY("id")
);

CREATE TABLE "audit_event" (
	"id" VARCHAR(255) NOT NULL,
	"org_id" VARCHAR(255) NOT NULL,
	"event_type" VARCHAR(50) NOT NULL,
	"timestamp" TIMESTAMP NOT NULL,
	"user_id" VARCHAR(255) NOT NULL,
	"workflow_definition_id" VARCHAR(255) NOT NULL,
	"resource" VARCHAR(255) NOT NULL,
	"workflow_instance_id" VARCHAR(255) NOT NULL,
	"comment" VARCHAR(191),
	PRIMARY KEY("id")
);

CREATE TABLE "org_workflow_config" (
	"id" VARCHAR(255) NOT NULL,
	"org_id" VARCHAR(255) NOT NULL,
	"assignee_roles" VARCHAR(255) NOT NULL,
	"assignees" VARCHAR(255) NOT NULL,
	"format_request_data" BOOLEAN NOT NULL,
	"external_workflow_engine_endpoint" VARCHAR(255),
	"workflow_definition_id" VARCHAR(255) NOT NULL,
	FOREIGN KEY("workflow_definition_id") REFERENCES "workflow_definition"("id"),
	PRIMARY KEY("id")
);

CREATE TABLE "workflow_instance" (
	"id" VARCHAR(255) NOT NULL,
	"org_id" VARCHAR(255) NOT NULL,
	"resource" VARCHAR(255) NOT NULL,
	"created_by" VARCHAR(255) NOT NULL,
	"created_time" TIMESTAMP NOT NULL,
	"request_comment" VARCHAR(191),
	"data" VARCHAR(191) NOT NULL,
	"status" VARCHAR(50) NOT NULL,
	"reviewed_by" VARCHAR(255),
	"reviewer_decision" VARCHAR(50),
	"review_comment" VARCHAR(191),
	"review_time" TIMESTAMP,
	"org_workflow_config_id" VARCHAR(255) NOT NULL,
	FOREIGN KEY("org_workflow_config_id") REFERENCES "org_workflow_config"("id"),
	"workflow_definition_id" VARCHAR(255) NOT NULL,
	FOREIGN KEY("workflow_definition_id") REFERENCES "workflow_definition"("id"),
	PRIMARY KEY("id")
);


