import ballerina/grpc;
import ballerina/protobuf;

public const string CARRENTALSYSTEM_DESC = "0A1563617272656E74616C73797374656D2E70726F746F120F63617272656E74616C73797374656D22B9010A0343617212120A046D616B6518012001280952046D616B6512140A056D6F64656C18022001280952056D6F64656C12120A0479656172180320012805520479656172121F0A0B6461696C795F7072696365180420012801520A6461696C79507269636512180A076D696C6561676518052001280552076D696C6561676512210A0C6E756D6265725F706C617465180620012809520B6E756D626572506C61746512160A06737461747573180720012809520673746174757322470A045573657212170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D6512120A04726F6C651803200128095204726F6C6522650A0652656E74616C12210A0C6E756D6265725F706C617465180120012809520B6E756D626572506C617465121D0A0A73746172745F64617465180220012809520973746172744461746512190A08656E645F646174651803200128095207656E644461746522330A0E416464436172526573706F6E736512210A0C6E756D6265725F706C617465180120012809520B6E756D626572506C617465226E0A105570646174654361725265717565737412210A0C6E756D6265725F706C617465180120012809520B6E756D626572506C617465121F0A0B6461696C795F7072696365180220012801520A6461696C79507269636512160A067374617475731803200128095206737461747573222D0A11557064617465436172526573706F6E736512180A076D65737361676518012001280952076D65737361676522350A1052656D6F76654361725265717565737412210A0C6E756D6265725F706C617465180120012809520B6E756D626572506C617465223C0A104C69737443617273526573706F6E736512280A046361727318012003280B32142E63617272656E74616C73797374656D2E43617252046361727322320A184C697374417661696C61626C65436172735265717565737412160A0666696C746572180120012809520666696C74657222350A105365617263684361725265717565737412210A0C6E756D6265725F706C617465180120012809520B6E756D626572506C617465225E0A11536561726368436172526573706F6E736512260A0363617218012001280B32142E63617272656E74616C73797374656D2E436172520363617212210A0C69735F617661696C61626C65180220012808520B6973417661696C61626C652288010A10416464546F436172745265717565737412170A07757365725F6964180120012809520675736572496412210A0C6E756D6265725F706C617465180220012809520B6E756D626572506C617465121D0A0A73746172745F64617465180320012809520973746172744461746512190A08656E645F646174651804200128095207656E644461746522280A0C43617274526573706F6E736512180A076D65737361676518012001280952076D65737361676522320A17506C6163655265736572766174696F6E5265717565737412170A07757365725F69641801200128095206757365724964225F0A135265736572766174696F6E526573706F6E7365121F0A0B746F74616C5F7072696365180120012801520A746F74616C507269636512270A0F636F6E6669726D6174696F6E5F6964180220012809520E636F6E6669726D6174696F6E496422070A05456D70747932A3050A1043617252656E74616C5365727669636512400A076164645F63617212142E63617272656E74616C73797374656D2E4361721A1F2E63617272656E74616C73797374656D2E416464436172526573706F6E7365123F0A0C6372656174655F757365727312152E63617272656E74616C73797374656D2E557365721A162E63617272656E74616C73797374656D2E456D707479280112530A0A7570646174655F63617212212E63617272656E74616C73797374656D2E557064617465436172526571756573741A222E63617272656E74616C73797374656D2E557064617465436172526573706F6E736512520A0A72656D6F76655F63617212212E63617272656E74616C73797374656D2E52656D6F7665436172526571756573741A212E63617272656E74616C73797374656D2E4C69737443617273526573706F6E736512580A136C6973745F617661696C61626C655F6361727312292E63617272656E74616C73797374656D2E4C697374417661696C61626C6543617273526571756573741A142E63617272656E74616C73797374656D2E436172300112530A0A7365617263685F63617212212E63617272656E74616C73797374656D2E536561726368436172526571756573741A222E63617272656E74616C73797374656D2E536561726368436172526573706F6E7365124F0A0B6164645F746F5F6361727412212E63617272656E74616C73797374656D2E416464546F43617274526571756573741A1D2E63617272656E74616C73797374656D2E43617274526573706F6E736512630A11706C6163655F7265736572766174696F6E12282E63617272656E74616C73797374656D2E506C6163655265736572766174696F6E526571756573741A242E63617272656E74616C73797374656D2E5265736572766174696F6E526573706F6E7365620670726F746F33";

public isolated client class CarRentalServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, CARRENTALSYSTEM_DESC);
    }

    isolated remote function add_car(Car|ContextCar req) returns AddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        Car message;
        if req is ContextCar {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/add_car", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <AddCarResponse>result;
    }

    isolated remote function add_carContext(Car|ContextCar req) returns ContextAddCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        Car message;
        if req is ContextCar {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/add_car", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <AddCarResponse>result, headers: respHeaders};
    }

    isolated remote function update_car(UpdateCarRequest|ContextUpdateCarRequest req) returns UpdateCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/update_car", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <UpdateCarResponse>result;
    }

    isolated remote function update_carContext(UpdateCarRequest|ContextUpdateCarRequest req) returns ContextUpdateCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        UpdateCarRequest message;
        if req is ContextUpdateCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/update_car", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <UpdateCarResponse>result, headers: respHeaders};
    }

    isolated remote function remove_car(RemoveCarRequest|ContextRemoveCarRequest req) returns ListCarsResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/remove_car", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ListCarsResponse>result;
    }

    isolated remote function remove_carContext(RemoveCarRequest|ContextRemoveCarRequest req) returns ContextListCarsResponse|grpc:Error {
        map<string|string[]> headers = {};
        RemoveCarRequest message;
        if req is ContextRemoveCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/remove_car", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ListCarsResponse>result, headers: respHeaders};
    }

    isolated remote function search_car(SearchCarRequest|ContextSearchCarRequest req) returns SearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/search_car", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <SearchCarResponse>result;
    }

    isolated remote function search_carContext(SearchCarRequest|ContextSearchCarRequest req) returns ContextSearchCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        SearchCarRequest message;
        if req is ContextSearchCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/search_car", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <SearchCarResponse>result, headers: respHeaders};
    }

    isolated remote function add_to_cart(AddToCartRequest|ContextAddToCartRequest req) returns CartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/add_to_cart", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <CartResponse>result;
    }

    isolated remote function add_to_cartContext(AddToCartRequest|ContextAddToCartRequest req) returns ContextCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        AddToCartRequest message;
        if req is ContextAddToCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/add_to_cart", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <CartResponse>result, headers: respHeaders};
    }

    isolated remote function place_reservation(PlaceReservationRequest|ContextPlaceReservationRequest req) returns ReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/place_reservation", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ReservationResponse>result;
    }

    isolated remote function place_reservationContext(PlaceReservationRequest|ContextPlaceReservationRequest req) returns ContextReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        PlaceReservationRequest message;
        if req is ContextPlaceReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("carrentalsystem.CarRentalService/place_reservation", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ReservationResponse>result, headers: respHeaders};
    }

    isolated remote function create_users() returns Create_usersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("carrentalsystem.CarRentalService/create_users");
        return new Create_usersStreamingClient(sClient);
    }

    isolated remote function list_available_cars(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns stream<Car, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("carrentalsystem.CarRentalService/list_available_cars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        CarStream outputStream = new CarStream(result);
        return new stream<Car, grpc:Error?>(outputStream);
    }

    isolated remote function list_available_carsContext(ListAvailableCarsRequest|ContextListAvailableCarsRequest req) returns ContextCarStream|grpc:Error {
        map<string|string[]> headers = {};
        ListAvailableCarsRequest message;
        if req is ContextListAvailableCarsRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("carrentalsystem.CarRentalService/list_available_cars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        CarStream outputStream = new CarStream(result);
        return {content: new stream<Car, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class Create_usersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUser(User message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUser(ContextUser message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveEmpty() returns Empty|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <Empty>payload;
        }
    }

    isolated remote function receiveContextEmpty() returns ContextEmpty|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <Empty>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class CarStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Car value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Car value;|} nextRecord = {value: <Car>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public type ContextUserStream record {|
    stream<User, error?> content;
    map<string|string[]> headers;
|};

public type ContextCarStream record {|
    stream<Car, error?> content;
    map<string|string[]> headers;
|};

public type ContextReservationResponse record {|
    ReservationResponse content;
    map<string|string[]> headers;
|};

public type ContextUser record {|
    User content;
    map<string|string[]> headers;
|};

public type ContextRemoveCarRequest record {|
    RemoveCarRequest content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarRequest record {|
    UpdateCarRequest content;
    map<string|string[]> headers;
|};

public type ContextAddCarResponse record {|
    AddCarResponse content;
    map<string|string[]> headers;
|};

public type ContextListCarsResponse record {|
    ListCarsResponse content;
    map<string|string[]> headers;
|};

public type ContextUpdateCarResponse record {|
    UpdateCarResponse content;
    map<string|string[]> headers;
|};

public type ContextAddToCartRequest record {|
    AddToCartRequest content;
    map<string|string[]> headers;
|};

public type ContextListAvailableCarsRequest record {|
    ListAvailableCarsRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarRequest record {|
    SearchCarRequest content;
    map<string|string[]> headers;
|};

public type ContextCartResponse record {|
    CartResponse content;
    map<string|string[]> headers;
|};

public type ContextEmpty record {|
    Empty content;
    map<string|string[]> headers;
|};

public type ContextCar record {|
    Car content;
    map<string|string[]> headers;
|};

public type ContextPlaceReservationRequest record {|
    PlaceReservationRequest content;
    map<string|string[]> headers;
|};

public type ContextSearchCarResponse record {|
    SearchCarResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type ReservationResponse record {|
    float total_price = 0.0;
    string confirmation_id = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type User record {|
    string user_id = "";
    string name = "";
    string role = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type RemoveCarRequest record {|
    string number_plate = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type UpdateCarRequest record {|
    string number_plate = "";
    float daily_price = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type AddCarResponse record {|
    string number_plate = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type ListCarsResponse record {|
    Car[] cars = [];
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type UpdateCarResponse record {|
    string message = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type AddToCartRequest record {|
    string user_id = "";
    string number_plate = "";
    string start_date = "";
    string end_date = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type ListAvailableCarsRequest record {|
    string filter = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type SearchCarRequest record {|
    string number_plate = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type CartResponse record {|
    string message = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type Empty record {|
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type Rental record {|
    string number_plate = "";
    string start_date = "";
    string end_date = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type Car record {|
    string make = "";
    string model = "";
    int year = 0;
    float daily_price = 0.0;
    int mileage = 0;
    string number_plate = "";
    string status = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type PlaceReservationRequest record {|
    string user_id = "";
|};

@protobuf:Descriptor {value: CARRENTALSYSTEM_DESC}
public type SearchCarResponse record {|
    Car car = {};
    boolean is_available = false;
|};
