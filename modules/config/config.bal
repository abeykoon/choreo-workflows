
// Ports
public configurable int servicePort = 9050;
public configurable int healthPort = 9082;

// Database configurations

public configurable string dbHost = "localhost";
public configurable string dbUsername = "postgres";
//public configurable string dbHost = ?;
//public configurable string dbUsername = ?;
//public configurable string dbPasswordPath = "/mnt/csi/secret-configuration-service/CONFIGURATION_SERVICE_DB_PASSWORD";
//public configurable string dbPassword = readStringFromFile(dbPasswordPath, "");
public configurable string dbPassword = "hasitha";
public configurable string dbName = "choreo_workflow_service_db";
