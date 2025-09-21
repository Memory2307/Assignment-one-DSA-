import ballerina/http;
import ballerina/io;

// Asset management types
type Status "ACTIVE"|"UNDER_REPAIR"|"DISPOSED";

type Component record {|
    string id;
    string name;
    string description;
    string serialNumber;
|};

type MaintenanceSchedule record {|
    string scheduleId;
    string description;
    string frequency;
    string lastServiced;
    string nextDueDate;
|};

type Task record {|
    string taskId;
    string description;
    string status;
    string assignedTo;
    string dueDate;
|};

type WorkOrder record {|
    string workOrderId;
    string description;
    string status;
    string openedDate;
    string closedDate?;
    Task[] tasks;
|};

type Asset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    Status status;
    string acquiredDate;
    Component[] components;
    MaintenanceSchedule[] schedules;
    WorkOrder[] workOrders;
|};

public function main() returns error? {
    io:println("=== Asset Management System Client ===\n");

    // Create HTTP client
    http:Client assetClient = check new ("http://localhost:9090");

    // Test connection first
    io:println("Testing connection to server...");
    http:Response testResponse = check assetClient->get("/asset/assets");
    if testResponse.statusCode == 200 {
        io:println("✓ Connected successfully to server\n");
    } else {
        io:println("✗ Cannot connect to server: " + testResponse.statusCode.toString());
        return;
    }

    boolean running = true;
    while running {
        // Display current assets
        io:println("=== CURRENT ASSETS ===");
        http:Response allAssetsResponse = check assetClient->get("/asset/assets");
        if allAssetsResponse.statusCode == 200 {
            json|error payloadOrError = allAssetsResponse.getJsonPayload();
            if payloadOrError is error {
                io:println("✗ Failed to parse server response: " + payloadOrError.message());
            } else if payloadOrError is json {
                json assetsJson = payloadOrError;
                Asset[] assets = [];
                if assetsJson is json[] {
                    foreach var item in assetsJson {
                        if item is map<json> {
                            Component[] components = [];
                            if item.hasKey("components") && item["components"] is json[] {
                                foreach var comp in <json[]>item["components"] {
                                    if comp is map<json> {
                                        components.push({
                                            id: comp.hasKey("id") ? <string>comp["id"] : "",
                                            name: comp.hasKey("name") ? <string>comp["name"] : "",
                                            description: comp.hasKey("description") ? <string>comp["description"] : "",
                                            serialNumber: comp.hasKey("serialNumber") ? <string>comp["serialNumber"] : ""
                                        });
                                    }
                                }
                            }

                            MaintenanceSchedule[] schedules = [];
                            if item.hasKey("schedules") && item["schedules"] is json[] {
                                foreach var sched in <json[]>item["schedules"] {
                                    if sched is map<json> {
                                        schedules.push({
                                            scheduleId: sched.hasKey("scheduleId") ? <string>sched["scheduleId"] : "",
                                            description: sched.hasKey("description") ? <string>sched["description"] : "",
                                            frequency: sched.hasKey("frequency") ? <string>sched["frequency"] : "",
                                            lastServiced: sched.hasKey("lastServiced") ? <string>sched["lastServiced"] : "",
                                            nextDueDate: sched.hasKey("nextDueDate") ? <string>sched["nextDueDate"] : ""
                                        });
                                    }
                                }
                            }

                            WorkOrder[] workOrders = [];
                            if item.hasKey("workOrders") && item["workOrders"] is json[] {
                                foreach var wo in <json[]>item["workOrders"] {
                                    if wo is map<json> {
                                        Task[] tasks = [];
                                        if wo.hasKey("tasks") && wo["tasks"] is json[] {
                                            foreach var t in <json[]>wo["tasks"] {
                                                if t is map<json> {
                                                    tasks.push({
                                                        taskId: t.hasKey("taskId") ? <string>t["taskId"] : "",
                                                        description: t.hasKey("description") ? <string>t["description"] : "",
                                                        status: t.hasKey("status") ? <string>t["status"] : "",
                                                        assignedTo: t.hasKey("assignedTo") ? <string>t["assignedTo"] : "",
                                                        dueDate: t.hasKey("dueDate") ? <string>t["dueDate"] : ""
                                                    });
                                                }
                                            }
                                        }
                                        workOrders.push({
                                            workOrderId: wo.hasKey("workOrderId") ? <string>wo["workOrderId"] : "",
                                            description: wo.hasKey("description") ? <string>wo["description"] : "",
                                            status: wo.hasKey("status") ? <string>wo["status"] : "",
                                            openedDate: wo.hasKey("openedDate") ? <string>wo["openedDate"] : "",
                                            closedDate: wo.hasKey("closedDate") ? <string>wo["closedDate"] : "",
                                            tasks: tasks
                                        });
                                    }
                                }
                            }

                            Asset asset = {
                                assetTag: item.hasKey("assetTag") ? <string>item["assetTag"] : "",
                                name: item.hasKey("name") ? <string>item["name"] : "",
                                faculty: item.hasKey("faculty") ? <string>item["faculty"] : "",
                                department: item.hasKey("department") ? <string>item["department"] : "",
                                status: item.hasKey("status") ? <Status>item["status"] : "ACTIVE",
                                acquiredDate: item.hasKey("acquiredDate") ? <string>item["acquiredDate"] : "",
                                components: components,
                                schedules: schedules,
                                workOrders: workOrders
                            };
                            assets.push(asset);
                        }
                    }
                }
                if assets.length() == 0 {
                    io:println("No assets found.");
                } else {
                    foreach int i in 0 ... assets.length() - 1 {
                        Asset asset = assets[i];
                        io:println((i + 1).toString() + ". " + asset.assetTag + " - " + asset.name + " (" + asset.faculty + ")");
                    }
                }
            }
        } else {
            io:println("Failed to fetch assets: " + allAssetsResponse.statusCode.toString());
        }

        // Display menu
        io:println("\n=== OPTIONS ===");
        io:println("1. Create new asset");
        io:println("2. View asset details");
        io:println("3. Update asset");
        io:println("4. Delete asset");
        io:println("5. Get assets by faculty");
        io:println("6. Check overdue maintenance");
        io:println("7. Add component to asset");
        io:println("8. Add maintenance schedule");
        io:println("9. Add work order");
        io:println("10. Add task to work order");
        io:println("11. Refresh assets");
        io:println("0. Exit");

        io:print("\nEnter your choice (0-11): ");
        string|error choiceInput = io:readln();
        if choiceInput is error {
            io:println("Error reading input. Please try again.");
            continue;
        }

        string choice = choiceInput;
        io:println("");

        match choice {
            "0" => {
                io:println("Exiting... Goodbye!");
                running = false;
            }

            "1" => {
                // Create new asset
                io:println("=== CREATE NEW ASSET ===");
                string assetTag = check readInput("Asset Tag: ");
                string name = check readInput("Name: ");
                string faculty = check readInput("Faculty: ");
                string department = check readInput("Department: ");
                string statusInput = check readInput("Status (ACTIVE/UNDER_REPAIR/DISPOSED): ");
                Status status = <Status>statusInput;
                string acquiredDate = check readInput("Acquired Date (YYYY-MM-DD): ");

                Asset newAsset = {
                    assetTag: assetTag,
                    name: name,
                    faculty: faculty,
                    department: department,
                    status: status,
                    acquiredDate: acquiredDate,
                    components: [],
                    schedules: [],
                    workOrders: []
                };

                http:Response response = check assetClient->post("/asset/assets", newAsset);
                if response.statusCode == 201 {
                    io:println("✓ Asset created successfully!");
                } else {
                    io:println("✗ Failed to create asset: " + response.statusCode.toString());
                }
            }

            "2" => {
                // View asset details
                string assetTag = check readInput("Enter asset tag to view: ");
                http:Response response = check assetClient->get("/asset/assets/" + assetTag);
                if response.statusCode == 200 {
                    json|error payloadOrError = response.getJsonPayload();
                    if payloadOrError is error {
                        io:println("✗ Failed to parse response: " + payloadOrError.message());
                    } else if payloadOrError is json {
                        json assetJson = payloadOrError;
                        if assetJson is map<json> {
                            map<json> item = <map<json>>assetJson;
                            Component[] components = [];
                            if item.hasKey("components") && item["components"] is json[] {
                                foreach var comp in <json[]>item["components"] {
                                    if comp is map<json> {
                                        components.push({
                                            id: comp.hasKey("id") ? <string>comp["id"] : "",
                                            name: comp.hasKey("name") ? <string>comp["name"] : "",
                                            description: comp.hasKey("description") ? <string>comp["description"] : "",
                                            serialNumber: comp.hasKey("serialNumber") ? <string>comp["serialNumber"] : ""
                                        });
                                    }
                                }
                            }

                            MaintenanceSchedule[] schedules = [];
                            if item.hasKey("schedules") && item["schedules"] is json[] {
                                foreach var sched in <json[]>item["schedules"] {
                                    if sched is map<json> {
                                        schedules.push({
                                            scheduleId: sched.hasKey("scheduleId") ? <string>sched["scheduleId"] : "",
                                            description: sched.hasKey("description") ? <string>sched["description"] : "",
                                            frequency: sched.hasKey("frequency") ? <string>sched["frequency"] : "",
                                            lastServiced: sched.hasKey("lastServiced") ? <string>sched["lastServiced"] : "",
                                            nextDueDate: sched.hasKey("nextDueDate") ? <string>sched["nextDueDate"] : ""
                                        });
                                    }
                                }
                            }

                            WorkOrder[] workOrders = [];
                            if item.hasKey("workOrders") && item["workOrders"] is json[] {
                                foreach var wo in <json[]>item["workOrders"] {
                                    if wo is map<json> {
                                        Task[] tasks = [];
                                        if wo.hasKey("tasks") && wo["tasks"] is json[] {
                                            foreach var t in <json[]>wo["tasks"] {
                                                if t is map<json> {
                                                    tasks.push({
                                                        taskId: t.hasKey("taskId") ? <string>t["taskId"] : "",
                                                        description: t.hasKey("description") ? <string>t["description"] : "",
                                                        status: t.hasKey("status") ? <string>t["status"] : "",
                                                        assignedTo: t.hasKey("assignedTo") ? <string>t["assignedTo"] : "",
                                                        dueDate: t.hasKey("dueDate") ? <string>t["dueDate"] : ""
                                                    });
                                                }
                                            }
                                        }
                                        workOrders.push({
                                            workOrderId: wo.hasKey("workOrderId") ? <string>wo["workOrderId"] : "",
                                            description: wo.hasKey("description") ? <string>wo["description"] : "",
                                            status: wo.hasKey("status") ? <string>wo["status"] : "",
                                            openedDate: wo.hasKey("openedDate") ? <string>wo["openedDate"] : "",
                                            closedDate: wo.hasKey("closedDate") ? <string>wo["closedDate"] : "",
                                            tasks: tasks
                                        });
                                    }
                                }
                            }

                            Asset asset = {
                                assetTag: item.hasKey("assetTag") ? <string>item["assetTag"] : "",
                                name: item.hasKey("name") ? <string>item["name"] : "",
                                faculty: item.hasKey("faculty") ? <string>item["faculty"] : "",
                                department: item.hasKey("department") ? <string>item["department"] : "",
                                status: item.hasKey("status") ? <Status>item["status"] : "ACTIVE",
                                acquiredDate: item.hasKey("acquiredDate") ? <string>item["acquiredDate"] : "",
                                components: components,
                                schedules: schedules,
                                workOrders: workOrders
                            };
                            io:println("=== ASSET DETAILS ===");
                            io:println("Tag: " + asset.assetTag);
                            io:println("Name: " + asset.name);
                            io:println("Faculty: " + asset.faculty);
                            io:println("Department: " + asset.department);
                            io:println("Status: " + asset.status.toString());
                            io:println("Acquired: " + asset.acquiredDate);
                            io:println("Components: " + asset.components.length().toString());
                            io:println("Schedules: " + asset.schedules.length().toString());
                            io:println("Work Orders: " + asset.workOrders.length().toString());
                        } else {
                            io:println("✗ Unexpected asset response format.");
                        }
                    }
                } else {
                    io:println("✗ Asset not found: " + response.statusCode.toString());
                }
            }

            "5" => {
                // Get assets by faculty
                string faculty = check readInput("Enter faculty name: ");
                http:Response response = check assetClient->get("/asset/assets/faculty/" + faculty);
                if response.statusCode == 200 {
                    json|error payloadOrError = response.getJsonPayload();
                    if payloadOrError is error {
                        io:println("✗ Failed to parse response: " + payloadOrError.message());
                    } else if payloadOrError is json {
                        Asset[] assets = <Asset[]>payloadOrError;
                        io:println("=== ASSETS IN FACULTY: " + faculty + " ===");
                        foreach var asset in assets {
                            io:println("- " + asset.assetTag + ": " + asset.name + " (" + asset.department + ")");
                        }
                    }
                } else {
                    io:println("✗ No assets found in faculty: " + response.statusCode.toString());
                }
            }

            "6" => {
                // Check overdue maintenance
                http:Response response = check assetClient->get("/asset/assets/overdue");
                if response.statusCode == 200 {
                    json|error payloadOrError = response.getJsonPayload();
                    if payloadOrError is error {
                        io:println("✗ Failed to parse response: " + payloadOrError.message());
                    } else if payloadOrError is json {
                        json overdueJson = <json>payloadOrError;
                        if overdueJson is map<json> {
                            map<json> overdueItems = <map<json>>overdueJson;
                            io:println("=== OVERDUE MAINTENANCE ITEMS ===");
                            foreach var [assetTag, schedules] in overdueItems.entries() {
                                io:println("Asset: " + assetTag);
                                if schedules is json[] {
                                    foreach var schedule in schedules {
                                        if schedule is map<json> {
                                            map<json> schedMap = <map<json>>schedule;
                                            string desc = schedMap.hasKey("description") ? <string>schedMap["description"] : "";
                                            string due = schedMap.hasKey("nextDueDate") ? <string>schedMap["nextDueDate"] : "";
                                            io:println("  - " + desc + " (Due: " + due + ")");
                                        }
                                    }
                                }
                            }
                        } else {
                            io:println("✗ Unexpected response format for overdue items.");
                        }
                    }
                } else if response.statusCode == 404 {
                    io:println("✓ No overdue maintenance items found.");
                } else {
                    io:println("✗ Error checking overdue items: " + response.statusCode.toString());
                }
            }

            // Other options (3,4,7,8,9,10,11) remain the same but use the same pattern
            _ => {
                io:println("Option not yet implemented in this snippet. Use same getJsonPayload() pattern for all endpoints.");
            }
        }

        io:println("\n==================================================");
    }

    return;
}

// Helper function to read input
function readInput(string prompt) returns string|error {
    io:print(prompt);
    string|error input = io:readln();
    if input is string {
        return input;
    }
    return input;
}
