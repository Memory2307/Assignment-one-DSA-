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

// Database simulation with sample data
map<Asset> assetDB = {
    "SERVER-001": {
        assetTag: "SERVER-001",
        name: "Main Server",
        faculty: "Computing & Informatics",
        department: "IT Services",
        status: "ACTIVE",
        acquiredDate: "2023-01-15",
        components: [
            {
                id: "COMP-001",
                name: "Hard Drive",
                description: "1TB SSD",
                serialNumber: "HD-12345"
            }
        ],
        schedules: [
            {
                scheduleId: "SCHED-001",
                description: "Monthly check",
                frequency: "MONTHLY",
                lastServiced: "2024-08-01",
                nextDueDate: "2024-09-01"
            }
        ],
        workOrders: []
    }
};

// Helper function to calculate days between dates
function daysBetween(string startDate, string endDate) returns int {
    return 30; // Placeholder
}

// Helper function for user input
function getInput(string prompt) returns string {
    io:println(prompt);
    string|error input = io:readln();
    if input is string {
        return input;
    }
    return "";
}

function handleInteractiveInput() {
    io:println("\nEnter command (or 'quit' to exit): ");
    string|error input = io:readln();
    
    if input is string {
        string command = input;
        if command == "quit" {
            io:println("Exiting interactive mode.");
            return;
        }
        // You can add more interactive commands here
        io:println("Unknown command. Type 'quit' to exit.");
    }
}

service /asset on new http:Listener(9090) {

    # Create a new asset
    resource function post assets(@http:Payload Asset asset) returns http:Created|http:BadRequest {
        if assetDB.hasKey(asset.assetTag) {
            return http:BAD_REQUEST;
        }
        assetDB[asset.assetTag] = asset;
        return http:CREATED;
    }

    # Get all assets
    resource function get assets() returns Asset[] {
        return assetDB.toArray();
    }

    # Get asset by tag
    resource function get assets/[string assetTag]() returns Asset|http:NotFound {
        if assetDB.hasKey(assetTag) {
            Asset? asset = assetDB[assetTag];
            if asset is Asset {
                return asset;
            }
        }
        return http:NOT_FOUND;
    }

    # Update asset
    resource function put assets/[string assetTag](@http:Payload Asset asset) 
    returns http:Ok|http:NotFound|http:BadRequest {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        if asset.assetTag != assetTag {
            return http:BAD_REQUEST;
        }
        assetDB[assetTag] = asset;
        return http:OK;
    }

    # Delete asset
    resource function delete assets/[string assetTag]() returns http:Ok|http:NotFound {
        if assetDB.hasKey(assetTag) {
            _ = assetDB.remove(assetTag);
            return http:OK;
        }
        return http:NOT_FOUND;
    }

    # Get assets by faculty
    resource function get assets/faculty/[string faculty]() returns Asset[] {
        Asset[] filteredAssets = [];
        foreach string assetTag in assetDB.keys() {
            Asset? asset = assetDB[assetTag];
            if asset is Asset && asset.faculty == faculty {
                filteredAssets.push(asset);
            }
        }
        return filteredAssets;
    }

    # Get overdue maintenance items
    resource function get assets/overdue() returns map<json>|http:NotFound {
        map<json> overdueAssets = {};
        string currentDate = "2024-09-15";
        
        foreach string assetTag in assetDB.keys() {
            Asset? asset = assetDB[assetTag];
            if asset is Asset {
                json[] overdueSchedules = [];
                foreach MaintenanceSchedule schedule in asset.schedules {
                    if schedule.nextDueDate < currentDate {
                        json overdueSchedule = {
                            assetTag: asset.assetTag,
                            assetName: asset.name,
                            scheduleId: schedule.scheduleId,
                            description: schedule.description,
                            nextDueDate: schedule.nextDueDate,
                            overdueBy: daysBetween(schedule.nextDueDate, currentDate)
                        };
                        overdueSchedules.push(overdueSchedule);
                    }
                }
                
                if overdueSchedules.length() > 0 {
                    overdueAssets[assetTag] = overdueSchedules;
                }
            }
        }
        
        if overdueAssets.length() == 0 {
            return http:NOT_FOUND;
        }
        return overdueAssets;
    }

    # Add component to asset
    resource function post assets/[string assetTag]/components(@http:Payload Component component) 
    returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        
        Asset? asset = assetDB[assetTag];
        if asset is Asset {
            asset.components.push(component);
            assetDB[assetTag] = asset;
            return http:OK;
        }
        return http:NOT_FOUND;
    }

    # Remove component from asset
    resource function delete assets/[string assetTag]/components/[string componentId]() 
    returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        
        Asset? asset = assetDB[assetTag];
        if asset is Asset {
            int index = -1;
            foreach int i in 0 ... asset.components.length() - 1 {
                if asset.components[i].id == componentId {
                    index = i;
                    break;
                }
            }
            
            if index == -1 {
                return http:NOT_FOUND;
            }
            
            _ = asset.components.remove(index);
            assetDB[assetTag] = asset;
            return http:OK;
        }
        return http:NOT_FOUND;
    }

    # Add maintenance schedule to asset
    resource function post assets/[string assetTag]/schedules(@http:Payload MaintenanceSchedule schedule) 
    returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        
        Asset? asset = assetDB[assetTag];
        if asset is Asset {
            asset.schedules.push(schedule);
            assetDB[assetTag] = asset;
            return http:OK;
        }
        return http:NOT_FOUND;
    }

    # Remove maintenance schedule from asset
    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() 
    returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        
        Asset? asset = assetDB[assetTag];
        if asset is Asset {
            int index = -1;
            foreach int i in 0 ... asset.schedules.length() - 1 {
                if asset.schedules[i].scheduleId == scheduleId {
                    index = i;
                    break;
                }
            }
            
            if index == -1 {
                return http:NOT_FOUND;
            }
            
            _ = asset.schedules.remove(index);
            assetDB[assetTag] = asset;
            return http:OK;
        }
        return http:NOT_FOUND;
    }

    # Add work order to asset
    resource function post assets/[string assetTag]/workorders(@http:Payload WorkOrder workOrder) 
    returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        
        Asset? asset = assetDB[assetTag];
        if asset is Asset {
            asset.workOrders.push(workOrder);
            assetDB[assetTag] = asset;
            return http:OK;
        }
        return http:NOT_FOUND;
    }

    # Add task to work order
    resource function post assets/[string assetTag]/workorders/[string workOrderId]/tasks(@http:Payload Task task) 
    returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        
        Asset? asset = assetDB[assetTag];
        if asset is Asset {
            foreach var workOrder in asset.workOrders {
                if workOrder.workOrderId == workOrderId {
                    workOrder.tasks.push(task);
                    assetDB[assetTag] = asset;
                    return http:OK;
                }
            }
        }
        
        return http:NOT_FOUND;
    }
}