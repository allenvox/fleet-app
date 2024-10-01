# fleet-app
![GitHub last commit](https://img.shields.io/github/last-commit/allenvox/fleet-app)<br><br>
A Swift-based system to manage a fleet of vehicles and simulate cargo transportation across various distances. The system supports different types of cargo (e.g., fragile, perishable, bulk) and ensures that each vehicle can carry specific types of cargo based on its configuration. It also simulates fuel consumption and ensures that vehicles can complete the assigned route before running out of fuel.

## Table of Contents
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Usage](#usage)
  - [Creating Vehicles and Trucks](#creating-vehicles-and-trucks)
  - [Creating and Loading Cargo](#creating-and-loading-cargo)
  - [Simulating Cargo Distribution and Travel](#simulating-cargo-distribution-and-travel)
- [Fleet Class](#fleet-class)
- [Vehicle and Truck Classes](#vehicle-and-truck-classes)
- [Cargo Class](#cargo-class)
- [CargoType Enum](#cargotype-enum)
- [License](#license)

## Features
- **Vehicle Management**: Manage a fleet of different types of vehicles (trucks, vans, etc.) with various load capacities.
- **Cargo Handling**: Support for loading and unloading different types of cargo, including fragile, perishable, and bulk.
- **Fuel Consumption**: Simulate fuel consumption based on distance and ensure that vehicles can return to refuel if necessary.
- **Trailer Support**: Some vehicles can attach a trailer for additional cargo capacity.
- **Automated Cargo Distribution**: Automatically distribute the cargo to available vehicles based on their capacity and cargo compatibility.
- **Flexible Cargo Type Handling**: Each vehicle has specific cargo types it can carry, and vehicles only accept cargos compatible with their type.

## Technologies Used
- **Swift**: The core language used to build the application.
- **Object-Oriented Programming (OOP)**: Classes and inheritance are used to define vehicle types, cargo, and the fleet.
- **Enums, Structs, and Optionals**: Used for defining cargo types and ensuring safe handling of optional values (e.g., trailers).

## Usage

### Creating Vehicles and Trucks

Create instances of `Vehicle` and `Truck` by specifying their make, model, capacity, fuel tank size, and allowed cargo types:

```swift
let vehicle1 = Vehicle(
    make: "Ford",
    model: "Transit",
    year: 2019,
    capacity: 1000,
    fuelTankCapacity: 80,
    allowedCargoTypes: [.fragile(inHardcase: false), .bulk(inBricks: true)]
)

let truck1 = Truck(
    make: "Volvo",
    model: "FH",
    year: 2020,
    capacity: 5000,
    fuelTankCapacity: 200,
    trailerAttached: true,
    trailerCapacity: 2000,
    allowedCargoTypes: [.fragile(inHardcase: true), .perishable(temperature: -10)]
)
```

### Creating and Loading Cargo

Create cargo and load it into vehicles using the `loadCargo` method:

```swift
let cargo1 = Cargo(description: "Musical equipment", weight: 300, type: .fragile(inHardcase: true))
let cargo2 = Cargo(description: "Medicines", weight: 200, type: .perishable(temperature: -5))

vehicle1.loadCargo(cargo: cargo1) // Loads fragile cargo
truck1.loadCargo(cargo: cargo2)   // Loads perishable cargo
```

### Simulating Cargo Distribution and Travel

You can check if your fleet can handle all the cargo and simulate travel with fuel constraints:

```swift
let cargos = [cargo1!, cargo2!]
let path = 300

fleet.canGo(cargo: cargos, path: path) // Checks if the fleet can carry all cargos for the specified distance
```

### Fleet Class

The `Fleet` class manages all vehicles in the system:

- **addVehicle(_ vehicle: Vehicle)**: Adds a vehicle to the fleet.
- **totalCapacity()**: Returns the total load capacity of all vehicles.
- **totalCurrentLoad()**: Returns the total current load of all vehicles.
- **canGo(cargo: [Cargo], path: Int)**: Distributes the cargo across vehicles and checks if the fleet can deliver it for the specified distance.

### Vehicle and Truck Classes

#### Vehicle

- **Properties**:
  - `make`: The brand of the vehicle.
  - `model`: The model of the vehicle.
  - `capacity`: Maximum load capacity (in kg).
  - `allowedCargoTypes`: Types of cargo the vehicle can carry.
  - `fuelTankCapacity`: Size of the fuel tank (in liters).
- **Methods**:
  - `loadCargo(cargo: Cargo)`: Loads cargo if it fits the capacity and cargo type restrictions.
  - `canGo(path: Int)`: Returns true if the vehicle has enough fuel to travel the specified path.

#### Truck

Inherits from `Vehicle` and adds trailer support:

- **Properties**:
  - `trailerAttached`: Indicates if the truck has a trailer.
  - `trailerCapacity`: The trailer’s additional load capacity.

### Cargo Class

Defines the cargo to be transported:

- **Properties**:
  - `description`: Description of the cargo.
  - `weight`: Weight of the cargo (in kg).
  - `type`: The type of cargo (fragile, perishable, or bulk).

### CargoType Enum

Defines different types of cargo:

- **Cases**:
  - `.fragile(inHardcase: Bool)`: Fragile cargo with an optional hard case.
  - `.perishable(temperature: Int)`: Perishable cargo that requires a specific temperature.
  - `.bulk(inBricks: Bool)`: Bulk cargo with an option to be transported in bricks.
  
Cargo types also support a computed property `.str` for descriptive string output.

Example:

```swift
let cargoType = CargoType.perishable(temperature: -10)
print(cargoType.str) // Outputs: "perishable (-10 degrees)"
```

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
