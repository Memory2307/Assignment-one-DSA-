import ballerina/io;
// import ballerina/grpc;

CarRentalServiceClient ep = check new ("http://localhost:9090");

public function main() returns error? {
    io:println("Welcome! Choose your role: 1-Admin 2-Customer");
    string roleStr = io:readln();
    int roleChoice = check int:fromString(roleStr);

    if roleChoice == 1 {
        io:println("Admin Operations:\n1-Add Car\n2-Update Car\n3-Remove Car\n4-Create User");
        string choiceStr = io:readln();
        int choice = check int:fromString(choiceStr);

        if choice == 1 {
            // Add Car
            io:println("Enter car make:"); string make = io:readln();
            io:println("Enter car model:"); string model = io:readln();
            io:println("Enter year:"); string yearStr = io:readln(); int year = check int:fromString(yearStr);
            io:println("Enter daily price:"); string dailyPriceStr = io:readln(); float dailyPrice = check float:fromString(dailyPriceStr);
            io:println("Enter mileage:"); string mileageStr = io:readln(); int mileage = check int:fromString(mileageStr);
            io:println("Enter number plate:"); string plate = io:readln();
            io:println("Enter status (Available/Reserved):"); string status = io:readln();

            Car newCar = { make: make, model: model, year: year, daily_price: dailyPrice,
                           mileage: mileage, number_plate: plate, status: status };
            AddCarResponse resp = check ep->add_car(newCar);
            io:println("Added Car: ", resp);

        } else if choice == 2 {
            // Update Car
            io:println("Enter number plate to update:"); string plate = io:readln();
            io:println("Enter new daily price:"); string priceStr = io:readln(); float price = check float:fromString(priceStr);
            io:println("Enter new status:"); string status = io:readln();

            UpdateCarRequest req = { number_plate: plate, daily_price: price, status: status };
            UpdateCarResponse resp = check ep->update_car(req);
            io:println("Updated Car: ", resp);

        } else if choice == 3 {
            // Remove Car
            io:println("Enter number plate to remove:"); string plate = io:readln();
            RemoveCarRequest req = { number_plate: plate };
            ListCarsResponse resp = check ep->remove_car(req);
            io:println("Remaining Cars: ", resp);

        } else if choice == 4 {
            // Create Users
            io:println("Enter user ID:"); string id = io:readln();
            io:println("Enter name:"); string name = io:readln();
            io:println("Enter role (Admin/Customer):"); string role = io:readln();

            User newUser = { user_id: id, name: name, role: role };

            // Handle union return type from create_users
            var streamingClientResult = ep->create_users();
            if streamingClientResult is Create_usersStreamingClient {
                Create_usersStreamingClient userStreamClient = streamingClientResult;
                check userStreamClient->sendUser(newUser);
                check userStreamClient->complete();
                Empty? resp = check userStreamClient->receiveEmpty();
                io:println("Created User: ", resp);
            } else {
                io:println("Failed to create user: ", streamingClientResult);
            }

        } else {
            io:println("Invalid choice!");
        }

    } else if roleChoice == 2 {
        io:println("Customer Operations:\n1-Search Car\n2-List Available Cars\n3-Add to Cart\n4-Place Reservation");
        string choiceStr = io:readln();
        int choice = check int:fromString(choiceStr);

        if choice == 1 {
            // Search Car
            io:println("Enter number plate to search:"); string plate = io:readln();
            SearchCarRequest req = { number_plate: plate };
            SearchCarResponse resp = check ep->search_car(req);
            io:println("Searched Car: ", resp);

        } else if choice == 2 {
            // List Available Cars
            io:println("Available Cars:");
            ListAvailableCarsRequest req = { filter: "" };
            stream<Car, error?> carStream = check ep->list_available_cars(req);
            _ = check carStream.forEach(function(Car value) {
                io:println(value);
            });

        } else if choice == 3 {
            // Add to Cart
            io:println("Enter your user ID:"); string userId = io:readln();
            io:println("Enter number plate to add to cart:"); string plate = io:readln();
            io:println("Enter rental start date (YYYY-MM-DD):"); string startDate = io:readln();
            io:println("Enter rental end date (YYYY-MM-DD):"); string endDate = io:readln();

            AddToCartRequest req = { user_id: userId, number_plate: plate, start_date: startDate, end_date: endDate };
            CartResponse resp = check ep->add_to_cart(req);
            io:println("Added to Cart: ", resp);

        } else if choice == 4 {
            // Place Reservation
            io:println("Enter your user ID to place reservation:"); string userId = io:readln();
            PlaceReservationRequest req = { user_id: userId };
            ReservationResponse resp = check ep->place_reservation(req);
            io:println("Placed Reservation: ", resp);

        } else {
            io:println("Invalid choice!");
        }

    } else {
        io:println("Invalid role choice!");
    }
}
