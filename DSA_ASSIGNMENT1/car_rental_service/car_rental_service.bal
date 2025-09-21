import ballerina/grpc;
import ballerina/log;
import ballerina/uuid;

// In-memory data storage
Car[] cars = [];
map<CartItem[]> userCarts = {};
Reservation[] reservations = [];
map<string> users = {}; // userId -> userName

listener grpc:Listener ep = new (9090);

@grpc:Descriptor {value: ONLINESHOPPING_DESC}
service "CarRentalService" on ep {

    // Initialize with some sample data
    function init() {
        // Add some sample cars
        cars.push({
            plate: "ABC123",
            make: "Toyota",
            model: "Camry",
            year: 2022,
            dailyPrice: 45.99,
            mileage: 25000,
            status: "AVAILABLE"
        });
        cars.push({
            plate: "XYZ789",
            make: "Honda",
            model: "Civic",
            year: 2021,
            dailyPrice: 39.99,
            mileage: 18000,
            status: "AVAILABLE"
        });
        cars.push({
            plate: "DEF456",
            make: "BMW",
            model: "X5",
            year: 2023,
            dailyPrice: 89.99,
            mileage: 5000,
            status: "RENTED"
        });

        log:printInfo("✅ Car Rental Service initialized with sample data");
    }

    // Add a new car (Admin operation)
    remote function addCar(AddCarRequest request) returns AddCarResponse|error {
        log:printInfo("Adding new car with plate: " + request.plate);

        // Check if car with same plate already exists
        foreach Car car in cars {
            if car.plate == request.plate {
                return error("Car with plate " + request.plate + " already exists");
            }
        }

        // Create new car
        Car newCar = {
            plate: request.plate,
            make: request.make,
            model: request.model,
            year: request.year,
            dailyPrice: request.dailyPrice,
            mileage: request.mileage,
            status: request.status
        };

        cars.push(newCar);
        log:printInfo("Car added successfully: " + request.plate);

        return {plate: request.plate};
    }

    // Update car details (Admin operation)
    remote function updateCar(UpdateCarRequest request) returns UpdateCarResponse|error {
        log:printInfo("Updating car with plate: " + request.plate);

        foreach int i in 0 ..< cars.length() {
            if cars[i].plate == request.plate {
                cars[i].dailyPrice = request.dailyPrice;
                cars[i].status = request.status;
                log:printInfo("Car updated successfully: " + request.plate);
                return {success: true, message: "Car updated successfully"};
            }
        }

        log:printError("Car not found with plate: " + request.plate);
        return {success: false, message: "Car not found with plate: " + request.plate};
    }

    // Remove a car (Admin operation)
    remote function removeCar(RemoveCarRequest request) returns RemoveCarResponse|error {
        log:printInfo("Removing car with plate: " + request.plate);

        Car[] updatedCars = [];
        boolean found = false;

        foreach Car car in cars {
            if car.plate != request.plate {
                updatedCars.push(car);
            } else {
                found = true;
            }
        }

        if found {
            cars = updatedCars;
            log:printInfo("Car removed successfully: " + request.plate);
        } else {
            log:printError("Car not found with plate: " + request.plate);
        }

        return {updatedCars: cars};
    }

    // List all reservations (Admin operation)
    remote function listAllReservations(EmptyRequest request) returns ReservationList|error {
        log:printInfo("Listing all reservations");
        return {reservations: reservations};
    }

    // Create users (Client streaming)
    remote function createUsers(stream<UserRequest, grpc:Error?> clientStream) returns CreateUsersResponse|error {
        log:printInfo("Starting user creation process");
        
        int userCount = 0;
        error? e = clientStream.forEach(function(UserRequest userReq) {
            users[userReq.userId] = userReq.userName;
            userCount += 1;
            log:printInfo("Created user: " + userReq.userName + " (" + userReq.userType + ")");
        });

        if e is error {
            log:printError("Error creating users: " + e.message());
            return e;
        }

        log:printInfo("User creation completed. Total users created: " + userCount.toString());
        return {numberOfUsersCreated: userCount};
    }

    // List available cars (Server streaming)
    remote function listAvailableCars(ListAvailableCarsRequest request) returns stream<Car, error?>|error {
        log:printInfo("Listing available cars with filter: " + request.filter);

        Car[] filteredCars = [];
        
        foreach Car car in cars {
            // Apply filter if provided
            if request.filter == "" {
                filteredCars.push(car);
            } else {
                string filterLower = request.filter.toLowerAscii();
                string makeLower = car.make.toLowerAscii();
                string modelLower = car.model.toLowerAscii();
                string yearStr = car.year.toString();
                string statusLower = car.status.toLowerAscii();

                if makeLower.includes(filterLower) || 
                   modelLower.includes(filterLower) || 
                   yearStr.includes(filterLower) || 
                   statusLower.includes(filterLower) {
                    filteredCars.push(car);
                }
            }
        }

        log:printInfo("Found " + filteredCars.length().toString() + " cars matching criteria");
        return filteredCars.toStream();
    }

    // Search for a specific car
    remote function searchCar(SearchCarRequest request) returns SearchCarResponse|error {
        log:printInfo("Searching for car with plate: " + request.plate);

        foreach Car car in cars {
            if car.plate == request.plate {
                log:printInfo("Car found: " + car.plate);
                return {
                    car: car,
                    message: "Car found successfully"
                };
            }
        }

        log:printInfo("Car not found with plate: " + request.plate);
        return {
            car: {
                plate: "",
                make: "",
                model: "",
                year: 0,
                dailyPrice: 0.0,
                mileage: 0,
                status: ""
            },
            message: "Car not found with plate: " + request.plate
        };
    }

    // Add car to user's cart
    remote function addToCart(AddToCartRequest request) returns CartResponse|error {
        log:printInfo("Adding car to cart for user: " + request.userId);

        boolean carExists = false;
        foreach Car car in cars {
            if car.plate == request.plate {
                carExists = true;
                if car.status != "AVAILABLE" {
                    return error("Car is not available for rental");
                }
                break;
            }
        }

        if !carExists {
            return error("Car not found with plate: " + request.plate);
        }

        CartItem newItem = {
            plate: request.plate,
            startDate: request.startDate,
            endDate: request.endDate
        };

        if userCarts.hasKey(request.userId) {
            CartItem[]? existingItems = userCarts[request.userId];
            if existingItems is CartItem[] {
                existingItems.push(newItem);
                userCarts[request.userId] = existingItems;
            }
        } else {
            userCarts[request.userId] = [newItem];
        }

        string cartId = uuid:createType1AsString();
        
        log:printInfo("Car added to cart successfully");
        return {
            cartId: cartId,
            items: userCarts[request.userId] ?: []
        };
    }

    // Place a reservation
    remote function placeReservation(PlaceReservationRequest request) returns ReservationResponse|error {
        log:printInfo("Placing reservation for user: " + request.userId);

        CartItem[]? cartItems = userCarts[request.userId];
        if cartItems is () || cartItems.length() == 0 {
            return error("No items found in cart for user: " + request.userId);
        }

        string reservationId = uuid:createType1AsString();
        Car[] reservedCars = [];
        float totalAmount = 0.0;

        foreach CartItem item in cartItems {
            foreach Car car in cars {
                if car.plate == item.plate {
                    reservedCars.push(car);
                    totalAmount += car.dailyPrice;
                    
                    foreach int i in 0 ..< cars.length() {
                        if cars[i].plate == car.plate {
                            cars[i].status = "RENTED";
                            break;
                        }
                    }
                    break;
                }
            }
        }

        Reservation newReservation = {
            reservationId: reservationId,
            userId: request.userId,
            cars: reservedCars,
            totalAmount: totalAmount,
            status: "CONFIRMED"
        };

        reservations.push(newReservation);
        userCarts[request.userId] = [];

        log:printInfo("Reservation placed successfully: " + reservationId);
        return {
            reservationId: reservationId,
            message: "Reservation placed successfully. Total amount: $" + totalAmount.toString()
        };
    }
}
