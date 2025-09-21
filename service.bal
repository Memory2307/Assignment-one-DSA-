import ballerina/http;
import ballerina/time;
import ballerina/io;

// Define status enum
public enum Status {
    ACTIVE,
    UNDER_REPAIR,
    DISPOSED
}

// Define types
public type Component record {|
    string id;
    string name;
    string description;
    string serialNumber;
|};

public type MaintenanceSchedule record {|
    string scheduleId;
    string description;
    string frequency; // "QUARTERLY", "YEARLY", "MONTHLY"
    time:Date nextDueDate;
    time:Date lastMaintained;
|};

public type Task record {|
    string taskId;
    string description;
    Status status;
    string assignedTo;
    time:Date dueDate;
|};

public type WorkOrder record {|
    string workOrderId;
    string description;
    Status status;
    time:Date openedDate;
    time:Date? closedDate;
    Task[] tasks;
|};

public type Asset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    Status status;
    time:Date acquiredDate;
    Component[] components;
    MaintenanceSchedule[] schedules;
    WorkOrder[] workOrders;
|};

// Database
map<Asset> assetDB = {};

// Service implementation
service /assets on new http:Listener(9090) {

    // Create a new asset
    resource function post .(@http:Payload Asset asset) returns http:Created|http:BadRequest {
        if assetDB.hasKey(asset.assetTag) {
            return http:BAD_REQUEST;
        }
        assetDB[asset.assetTag] = asset;
        return http:CREATED;
    }

    // Get all assets
    resource function get .() returns Asset[] {
        return assetDB.toArray();
    }

    // Get asset by tag
    resource function get ./[string assetTag]() returns Asset|http:NotFound {
        if assetDB.hasKey(assetTag) {
            return assetDB[assetTag];
        }
        return http:NOT_FOUND;
    }

    // Update asset
    resource function put ./[string assetTag](@http:Payload Asset asset) returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        assetDB[assetTag] = asset;
        return http:OK;
    }

    // Delete asset
    resource function delete ./[string assetTag]() returns http:Ok|http:NotFound {
        if assetDB.hasKey(assetTag) {
            _ = assetDB.remove(assetTag);
            return http:OK;
        }
        return http:NOT_FOUND;
    }

    // Get assets by faculty
    resource function get ./faculty/[string faculty]() returns Asset[] {
        Asset[] filteredAssets = [];
        foreach var asset in assetDB {
            if asset.faculty == faculty {
                filteredAssets.push(asset);
            }
        }
        return filteredAssets;
    }

    // Get overdue maintenance items
    resource function get ./overdue() returns map<Asset[]>|http:InternalServerError {
        map<Asset[]> result = {};
        time:Date currentDate = time:utcNow().date();
        
        foreach var asset in assetDB {
            foreach var schedule in asset.schedules {
                if schedule.nextDueDate < currentDate {
                    if !result.hasKey(asset.faculty) {
                        result[asset.faculty] = [];
                    }
                    result[asset.faculty].push(asset);
                    break;
                }
            }
        }
        return result;
    }

    // Manage components
    resource function post ./[string assetTag]/components(@http:Payload Component component) 
    returns http:Created|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        assetDB[assetTag].components.push(component);
        return http:CREATED;
    }

    resource function delete ./[string assetTag]/components/[string componentId]() 
    returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        
        Component[] filteredComponents = [];
        foreach var component in assetDB[assetTag].components {
            if component.id != componentId {
                filteredComponents.push(component);
            }
        }
        assetDB[assetTag].components = filteredComponents;
        return http:OK;
    }

    // Manage maintenance schedules
    resource function post ./[string assetTag]/schedules(@http:Payload MaintenanceSchedule schedule) 
    returns http:Created|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        assetDB[assetTag].schedules.push(schedule);
        return http:CREATED;
    }

    resource function delete ./[string assetTag]/schedules/[string scheduleId]() 
    returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        
        MaintenanceSchedule[] filteredSchedules = [];
        foreach var schedule in assetDB[assetTag].schedules {
            if schedule.scheduleId != scheduleId {
                filteredSchedules.push(schedule);
            }
        }
        assetDB[assetTag].schedules = filteredSchedules;
        return http:OK;
    }

    // Manage work orders
    resource function post ./[string assetTag]/workorders(@http:Payload WorkOrder workOrder) 
    returns http:Created|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        assetDB[assetTag].workOrders.push(workOrder);
        return http:CREATED;
    }

    // Manage tasks within work orders
    resource function post ./[string assetTag]/workorders/[string workOrderId]/tasks(@http:Payload Task task) 
    returns http:Created|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        
        foreach var workOrder in assetDB[assetTag].workOrders {
            if workOrder.workOrderId == workOrderId {
                workOrder.tasks.push(task);
                return http:CREATED;
            }
        }
        return http:NOT_FOUND;
    }

    resource function delete ./[string assetTag]/workorders/[string workOrderId]/tasks/[string taskId]() 
    returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NOT_FOUND;
        }
        
        foreach var workOrder in assetDB[assetTag].workOrders {
            if workOrder.workOrderId == workOrderId {
                Task[] filteredTasks = [];
                foreach var task in workOrder.tasks {
                    if task.taskId != taskId {
                        filteredTasks.push(task);
                    }
                }
                workOrder.tasks = filteredTasks;
                return http:OK;
            }
        }
        return http:NOT_FOUND;
    }
}