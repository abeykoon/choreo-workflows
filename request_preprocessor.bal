// Copyright (c) 2023 WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/http;
import ballerina/uuid;
import ballerina/jwt;
import workflow_mgt_service.util;

service class RequestPreProcessor {
    *http:RequestInterceptor;

    resource function 'default [string... path](
            http:RequestContext ctx,
            http:Request req) returns
                http:NextService|http:Unauthorized|http:HeaderNotFoundError|error? {
        util:Context logContext = util:getContext(ctx);
        // Sets request id
        string|http:HeaderNotFoundError requestIdHeaderValue = req.getHeader(util:REQUEST_ID_HEADER);
        if requestIdHeaderValue is string {
            ctx.set(util:REQUEST_ID, requestIdHeaderValue);
        } else {
            ctx.set(util:REQUEST_ID, uuid:createType4AsString());
        }

        // Sets organization id
        string|http:HeaderNotFoundError jwtToken = req.getHeader(util:JWT_HEADER);
        if jwtToken is http:HeaderNotFoundError {
            string errorMsg = string `JWT header ${util:JWT_HEADER} is not found in the request.`;
            util:logError(logContext, errorMsg, ());
            http:Unauthorized unauthorized = {body: {"message": "Unauthorized access. Please provide a valid JWT header"}};
            return unauthorized;
        } else {
            // Authnenticates the request
            error? authzResult = self.validateAndExtractInfo(ctx, jwtToken);
            if (authzResult is error) {
                util:logError(logContext, "Unorthorized access", authzResult);
                http:Unauthorized unauthorized = {body: {"message": authzResult.message()}};
                return unauthorized;
            }
        }
        return ctx.next();
    }

    isolated function validateAndExtractInfo(http:RequestContext ctx, string token) returns error? {
        jwt:ValidatorConfig config = {};
        jwt:Payload jwt = check jwt:validate(token, config);
        util:OrganizationInfo orgInfo = check self.getOrgInfoFromToken(jwt);
        ctx.set(util:ORGANIZATION_ID, orgInfo.uuid);
        ctx.set(util:ORGANIZATION_HANDLE, orgInfo.'handle);
        ctx.set(util:USER_ID, check self.getIdpUserEmailFromToken(jwt));
    }

    isolated function getOrgInfoFromToken(jwt:Payload decodedToken) returns util:OrganizationInfo|error {
        json scopeDetails = check decodedToken[util:ORG_KEY_IN_JWT].ensureType();
        return scopeDetails.fromJsonWithType();
    }
    isolated function getIdpUserEmailFromToken(jwt:Payload decodedToken) returns string|error {
        json idpClaims = check decodedToken[util:IDP_CLAIMS_KEY_IN_JWT].ensureType();
        string email =  check idpClaims.email;
        return email;
    }
}
