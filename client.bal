import ballerina/io;
import ballerina/grpc;

public function main() returns error? {
    // Connect to the gRPC server
    CarRentalServiceClient clientEp = check new ("http://localhost:9090");

    io:println("==== Car Rental Client ====");

    // Ask the role at the start
    string role = io:readln("Are you an Admin or a Customer? (Enter A/C): ");

    if role.toUpperAscii() == "A" {
        io:println("\n=== Admin Menu ===");
        
        // Admin function 1: Add a car
        string addChoice = io:readln("\nDo you want to add a new car? (y/n): ");
        if addChoice.toLowerAscii() == "y" {
            string make = io:readln("Enter car make: ");
            string model = io:readln("Enter car model: ");
            string yearStr = io:readln("Enter car year: ");
            string priceStr = io:readln("Enter daily price: ");
            string mileageStr = io:readln("Enter mileage: ");
            string plateNum = io:readln("Enter plate number: ");
            string status = io:readln("Enter status (AVAILABLE/RENTED): ");

            int|error year = int:fromString(yearStr);
            float|error dailyPrice = float:fromString(priceStr);
            int|error mileage = int:fromString(mileageStr);

            if year is int && dailyPrice is float && mileage is int {
                AddCarRequest addReq = {
                    make: make,
                    model: model,
                    year: year,
                    dailyPrice: dailyPrice,
                    mileage: mileage,
                    plate: plateNum,
                    status: status
                };

                AddCarResponse|grpc:Error addRes = clientEp->addCar(addReq);
                if addRes is AddCarResponse {
                    io:println("Car added successfully with plate: ", addRes.plate);
                } else {
                    io:println("Error adding car: ", addRes.message());
                }
            } else {
                io:println("Invalid input for numeric fields");
            }
        }

        // Admin function 2: Create users (streaming)
        string createUsersChoice = io:readln("\nDo you want to create users? (y/n): ");
        if createUsersChoice.toLowerAscii() == "y" {
            CreateUsersStreamingClient|grpc:Error streamingClient = clientEp->createUsers();
            
            if streamingClient is CreateUsersStreamingClient {
                string continueCreating = "y";
                while continueCreating.toLowerAscii() == "y" {
                    string userId = io:readln("Enter user ID: ");
                    string userName = io:readln("Enter user name: ");
                    string userType = io:readln("Enter user type (admin/customer): ");
                    
                    UserRequest userReq = {
                        userId: userId,
                        userName: userName,
                        userType: userType
                    };
                    
                    grpc:Error? sendResult = streamingClient->sendUserRequest(userReq);
                    if sendResult is grpc:Error {
                        io:println("Error sending user request: ", sendResult.message());
                    } else {
                        io:println("User request sent successfully");
                    }
                    
                    continueCreating = io:readln("Create another user? (y/n): ");
                }
                
                // Complete the stream and get response
                grpc:Error? completeResult = streamingClient->complete();
                if completeResult is grpc:Error {
                    io:println("Error completing stream: ", completeResult.message());
                } else {
                    CreateUsersResponse|grpc:Error? response = streamingClient->receiveCreateUsersResponse();
                    if response is CreateUsersResponse {
                        io:println("Users created successfully. Total: ", response.numberOfUsersCreated);
                    } else if response is grpc:Error {
                        io:println("Error receiving response: ", response.message());
                    }
                }
            } else {
                io:println("Error creating streaming client: ", streamingClient.message());
            }
        }

        // Admin function 3: List all reservations
        string listReservationsChoice = io:readln("\nDo you want to list all reservations? (y/n): ");
        if listReservationsChoice.toLowerAscii() == "y" {
            EmptyRequest emptyReq = {};
            ReservationList|grpc:Error reservationList = clientEp->listAllReservations(emptyReq);
            
            if reservationList is ReservationList {
                io:println("\n--- All Reservations ---");
                foreach Reservation reservation in reservationList.reservations {
                    io:println(string `Reservation ID: ${reservation.reservationId} | User ID: ${reservation.userId} | Total: $${reservation.totalAmount} | Status: ${reservation.status}`);
                }
            } else {
                io:println("Error listing reservations: ", reservationList.message());
            }
        }

    } else if role.toUpperAscii() == "C" {
        io:println("\n=== Customer Menu ===");
        
        // Customer function 1: List available cars
        string filter = io:readln("Enter filter for available cars (e.g. Toyota or 2022, leave empty for all): ");
        ListAvailableCarsRequest listReq = { filter: filter };

        io:println("\n--- Available Cars ---");
        stream<Car, grpc:Error?>|grpc:Error carsResult = clientEp->listAvailableCars(listReq);
        
        if carsResult is stream<Car, grpc:Error?> {
            error? result = carsResult.forEach(function(Car car) {
                io:println(string `Plate: ${car.plate} | Make: ${car.make} | Model: ${car.model} | Year: ${car.year} | Daily Price: $${car.dailyPrice} | Status: ${car.status}`);
            });
            
            if result is error {
                io:println("Error processing cars: ", result.message());
            }
        } else {
            io:println("Error listing cars: ", carsResult.message());
        }

        // Customer function 2: Search for a specific car
        string plate = io:readln("\nEnter car plate to search: ");
        SearchCarRequest searchReq = { plate: plate };
        SearchCarResponse|grpc:Error searchRes = clientEp->searchCar(searchReq);
        
        if searchRes is SearchCarResponse {
            io:println("Search Result: ", searchRes.message);
            if searchRes.car.plate != "" {
                Car car = searchRes.car;
                io:println(string `Found Car - Plate: ${car.plate} | Make: ${car.make} | Model: ${car.model} | Year: ${car.year} | Daily Price: $${car.dailyPrice} | Status: ${car.status}`);
            }
        } else {
            io:println("Error searching for car: ", searchRes.message());
        }

        // Customer function 3: Add car to cart
        string cartChoice = io:readln("\nDo you want to add a car to cart? (y/n): ");
        if cartChoice.toLowerAscii() == "y" {
            string userId = io:readln("Enter your user ID: ");
            string carPlate = io:readln("Enter car plate to add to cart: ");
            string startDate = io:readln("Enter start date (YYYY-MM-DD): ");
            string endDate = io:readln("Enter end date (YYYY-MM-DD): ");

            AddToCartRequest cartReq = {
                userId: userId,
                plate: carPlate,
                startDate: startDate,
                endDate: endDate
            };

            CartResponse|grpc:Error cartRes = clientEp->addToCart(cartReq);
            if cartRes is CartResponse {
                io:println("Added to cart successfully. Cart ID: ", cartRes.cartId);
                io:println("Items in cart: ", cartRes.items.length());
            } else {
                io:println("Error adding to cart: ", cartRes.message());
            }
        }

        // Customer function 4: Place reservation
        string reservationChoice = io:readln("\nDo you want to place a reservation? (y/n): ");
        if reservationChoice.toLowerAscii() == "y" {
            string userId = io:readln("Enter your user ID: ");
            string cartId = io:readln("Enter your cart ID: ");

            PlaceReservationRequest reservationReq = {
                userId: userId,
                cartId: cartId
            };

            ReservationResponse|grpc:Error reservationRes = clientEp->placeReservation(reservationReq);
            if reservationRes is ReservationResponse {
                io:println("Reservation placed successfully!");
                io:println("Reservation ID: ", reservationRes.reservationId);
                io:println("Message: ", reservationRes.message);
            } else {
                io:println("Error placing reservation: ", reservationRes.message());
            }
        }

    } else {
        io:println("Invalid role selected. Please enter 'A' for Admin or 'C' for Customer.");
        return;
    }

    io:println("\n==== Client Session Completed ====");
}
