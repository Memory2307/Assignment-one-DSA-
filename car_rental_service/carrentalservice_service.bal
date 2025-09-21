import ballerina/grpc;
import ballerina/time;
import ballerina/lang.array; // for toStream

listener grpc:Listener ep = new(9090);

@grpc:Descriptor {value: CARRENTALSYSTEM_DESC}
service "CarRentalService" on ep {

    // ------------------ SERVICE-LEVEL STORAGE ------------------
    map<Car> cars = {};
    map<User> users = {};
    map<string> carts = {}; // user_id -> number_plate
    map<ReservationResponse> reservations = {}; // confirmation_id -> reservation

    // ------------------ ADMIN ------------------
    remote function add_car(Car car) returns AddCarResponse|error {
        if self.cars.hasKey(car.number_plate) {
            return error("Car already exists");
        }
        self.cars[car.number_plate] = car;
        return { number_plate: car.number_plate };
    }

    remote function update_car(UpdateCarRequest req) returns UpdateCarResponse|error {
        Car? car = self.cars[req.number_plate];
        if car is () {
            return error("Car not found");
        }
        car.daily_price = req.daily_price;
        car.status = req.status;
        self.cars[req.number_plate] = car;
        return { message: "Car updated successfully" };
    }

    remote function remove_car(RemoveCarRequest req) returns ListCarsResponse|error {
    if !self.cars.hasKey(req.number_plate) {
        return error("Car not found");
    }

    _ = self.cars.remove(req.number_plate);

    // Collect remaining cars into an array
    Car[] carList = [];
    foreach var [_, car] in self.cars.entries() {
        carList.push(car);
    }

    return { cars: carList };
}


    remote function create_users(stream<User, error?> userStream) returns Empty|error {
        check userStream.forEach(function(User u) {
            self.users[u.user_id] = u;
        });
        return {};
    }

    // ------------------ CUSTOMER ------------------
    remote function search_car(SearchCarRequest req) returns SearchCarResponse|error {
        Car? car = self.cars[req.number_plate];
        if car is () {
            return error("Car not found");
        }
        boolean available = car.status == "Available";
        return { car: car, is_available: available };
    }

    remote function list_available_cars(ListAvailableCarsRequest req) 
            returns stream<Car, grpc:Error?>|grpc:Error {
        Car[] availableCars = [];
    foreach var [_, car] in self.cars.entries() {
            if car.status == "Available" {
                availableCars.push(car);
            }
        }

        // Convert array to stream
        return array:toStream(availableCars);
    }

    remote function add_to_cart(AddToCartRequest req) returns CartResponse|error {
        Car? car = self.cars[req.number_plate];
        if car is () {
            return error("Car not found");
        }
        if car.status != "Available" {
            return error("Car not available");
        }
        self.carts[req.user_id] = req.number_plate;
        return { message: "Car added to cart" };
    }

    remote function place_reservation(PlaceReservationRequest req) returns ReservationResponse|error {
        string? plate = self.carts[req.user_id];
        if plate is () {
            return error("Cart is empty");
        }

        Car? car = self.cars[plate];
        if car is () {
            return error("Car not found");
        }

        float price = car.daily_price * 1; // extend for multiple days
        time:Utc currentUtc = time:utcNow();
        string confirmationId = "RES" + currentUtc[0].toString();

        self.reservations[confirmationId] = { 
            total_price: price, 
            confirmation_id: confirmationId 
        };

        car.status = "Reserved";
        self.cars[plate] = car;

        _ = self.carts.remove(req.user_id); // empty cart after reservation
        return { total_price: price, confirmation_id: confirmationId };
    }
}
