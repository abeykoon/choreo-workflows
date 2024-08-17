INSERT INTO public.workflow_definition
(id, "name", description, approver_types, execute_upon_approval, allow_parallel_requests, request_format_schema)
VALUES('ENV_PROMOTION', 'Environment Promotion','Promotion of a build from one environment to another', 'ROLE,USER', false, false, '{"name":{"displayName":"Name", "dataType":"string", "extractfrom":"data.name"}, "age":{"displayName":"Age", "dataType":"int", "extractfrom":"data.age"}, "address":{"displayName":"Address", "dataType":"string", "extractfrom":"data.location.address"}}');
INSERT INTO public.workflow_definition
(id, "name", description, approver_types, execute_upon_approval, allow_parallel_requests, request_format_schema)
VALUES('PROJECT_DELETE', 'Project Deletion','Deleting a project from an organization', 'ROLE,USER', false, false, '{"quantity":{"displayName":"Number Of Rooms", "dataType":"string", "extractfrom":"data.rooms"}, "quality":{"displayName":"Quality Level", "dataType":"int", "extractfrom":"data.rooms.quality"}, "duration":{"displayName":"Number of Days", "dataType":"string", "extractfrom":"data.stay.duration"}}');
INSERT INTO public.workflow_definition
(id, "name", description, approver_types, execute_upon_approval, allow_parallel_requests, request_format_schema)
VALUES('PROJECT_CREATE', 'Project Creation','Creating a new project within an organization', 'ROLE,USER', true, true, '{"name":{"displayName":"Project Name", "dataType":"string", "extractfrom":"data.project.name"}}');
