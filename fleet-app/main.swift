//
//  main.swift
//  fleet-app
//
//  Created by Yuriy Grigoryev on 30.09.2024.
//

import Foundation

class Vehicle {
    let make: String
    let model: String
    let year: Int
    let capacity: Int
    var currentLoad: Int? = 0
    let fuelTankCapacity: Double
    var allowedCargoTypes: [CargoType]?

    init(make: String, model: String, year: Int, capacity: Int, fuelTankCapacity: Double, allowedCargoTypes: [CargoType]? = nil) {
        self.make = make
        self.model = model
        self.year = year
        self.capacity = capacity
        self.fuelTankCapacity = fuelTankCapacity
        self.allowedCargoTypes = allowedCargoTypes
    }

    func loadCargo(cargo: Cargo?) -> Bool {
        guard cargo != nil else {
            print("Failed to load empty cargo on the vehicle")
            return false
        }
        
        let isSupportedCargo = allowedCargoTypes?.contains(cargo!.type)
        
        if !(isSupportedCargo ?? true) { // if allowedCargoTypes is nil, all types supported
            print("'\(make) \(model)' can not handle '\(cargo!.type.str)' cargo")
            return false
        }
        
        guard let currentLoad = currentLoad else {
            self.currentLoad = cargo!.weight
            print("Cargo loaded to '\(make) \(model)': '\(cargo!.description)'")
            return true
        }
        
        if currentLoad + cargo!.weight > capacity {
            print("'\(make) \(model)' can not handle weight of '\(cargo!.description)'")
            return false
        }
        
        self.currentLoad! += cargo!.weight
        print("Cargo loaded to '\(make) \(model)': '\(cargo!.description)'")
        return true
    }

    func unloadCargo() {
        self.currentLoad = 0
    }
    
    func canGo(path: Int) -> Bool {
        let kmPerLiter = 14.0 // fuel consumption
        let maxDistance = Int((fuelTankCapacity / 2) * kmPerLiter)
        return path <= maxDistance
    }
}

class Truck: Vehicle {
    var trailerAttached: Bool
    var trailerCapacity: Int?
    var trailerCurrentLoad: Int = 0
    var trailerAllowedCargoTypes: [CargoType]?

    init(make: String, model: String, year: Int, capacity: Int, fuelTankCapacity: Double, trailerAttached: Bool, trailerCapacity: Int?, allowedCargoTypes: [CargoType]? = nil, trailerAllowedCargoTypes: [CargoType]? = nil) {
        self.trailerAttached = trailerAttached
        self.trailerCapacity = trailerCapacity
        self.trailerAllowedCargoTypes = trailerAllowedCargoTypes
        super.init(make: make, model: model, year: year, capacity: capacity, fuelTankCapacity: fuelTankCapacity, allowedCargoTypes: allowedCargoTypes)
    }
    
    override func loadCargo(cargo: Cargo?) -> Bool {
        guard let cargo = cargo else {
            print("Failed to load empty cargo on the vehicle")
            return false
        }
        
        let isSupportedByTruck = allowedCargoTypes?.contains(cargo.type) ?? true
        let isSupportedByTrailer = trailerAllowedCargoTypes?.contains(cargo.type) ?? false

        if isSupportedByTruck && (currentLoad! + cargo.weight <= capacity) {
            self.currentLoad! += cargo.weight
            print("Cargo loaded to truck '\(make) \(model)': '\(cargo.description)'")
            return true
        }

        if trailerAttached && isSupportedByTrailer {
            if trailerCurrentLoad + cargo.weight <= trailerCapacity! {
                trailerCurrentLoad += cargo.weight
                print("Cargo loaded to trailer of '\(make) \(model)': '\(cargo.description)'")
                return true
            } else {
                print("Trailer of '\(make) \(model)' can't handle the weight of '\(cargo.description)'")
                return false
            }
        }
        
        print("'\(make) \(model)' can't carry cargo type '\(cargo.type.str)'")
        return false
    }
    
    override func unloadCargo() {
        super.unloadCargo()
        trailerCurrentLoad = 0
    }
    
    func totalCapacity() -> Int {
        return capacity + (trailerCapacity ?? 0)
    }

    func totalCurrentLoad() -> Int {
        return currentLoad! + trailerCurrentLoad
    }
}

enum CargoType: Equatable {
    case fragile(inHardcase: Bool)
    case perishable(temperature: Int)
    case bulk(inBricks: Bool)
    
    var str : String {
        switch self {
        case .fragile(let value): return "fragile" + (value ? " in hardcase" : "")
        case .perishable(let value): return "perishable" + " (\(value) degrees)"
        case .bulk(let value): return "bulk" + (value ? " in bricks" : "")
        }
    }
}

struct Cargo {
    let description: String
    let weight: Int
    let type: CargoType
    
    init?(description: String, weight: Int, type: CargoType) {
        if weight <= 0 {
            print("Cargo weight should be greater than 0")
            return nil
        }
        self.description = description
        self.weight = weight
        self.type = type
    }
}

class Fleet {
    var vehicles: [Vehicle] = []
    
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
        var vehicleInfo = "'\(vehicle.make) \(vehicle.model)' that can carry '\(vehicle.allowedCargoTypes?.map { $0.str }.joined(separator: ", ") ?? "all")' cargos with total weight of \(vehicle.capacity) kg"
        
        if let truck = vehicle as? Truck, truck.trailerAttached {
            let trailerCargoTypes = truck.trailerAllowedCargoTypes?.map { $0.str }.joined(separator: ", ") ?? "all"
            vehicleInfo += " and has a trailer with additional capacity of \(truck.trailerCapacity ?? 0) kg for '\(trailerCargoTypes)' cargo types"
        }
        
        print("\(vehicleInfo) added to fleet")
    }
    
    func totalCapacity() -> Int {
        return vehicles.reduce(0) { $0 + $1.capacity }
    }
    
    func totalCurrentLoad() -> Int {
        return vehicles.reduce(0) { $0 + ($1.currentLoad ?? 0) }
    }
    
    func info() {
        print("Fleet's weight capacity: \(fleet.totalCapacity()) kg")
        print("Fleet's current load: \(fleet.totalCurrentLoad()) kg")
    }
    
    func canGo(cargo: [Cargo], path: Int) -> Bool {
        print("Can the fleet carry cargos on \(path) km route?")
        
        var loadedVehicles: [Vehicle] = []
        
        for load in cargo {
            var isCargoLoaded = false
            
            for vehicle in vehicles {
                if (vehicle.allowedCargoTypes?.contains(load.type) ?? true) {
                    if vehicle.loadCargo(cargo: load) {
                        loadedVehicles.append(vehicle)
                        isCargoLoaded = true
                        break
                    }
                }
            }
            
            if !isCargoLoaded {
                print("Could not find vehicle to carry '\(load.description)', '\(load.type.str)' cargo")
                return false
            }
        }
        
        for vehicle in loadedVehicles {
            if !vehicle.canGo(path: path) {
                print("'\(vehicle.make) \(vehicle.model)' can not ride \(path) km route due to fuel amounts")
                return false
            }
        }
        
        print("Cargo can be carried on \(path) km route")
        for vehicle in fleet.vehicles {
            vehicle.unloadCargo()
        }
        return true
    }
}

let vehicle1 = Vehicle(
    make: "Ford",
    model: "Transit",
    year: 2019,
    capacity: 1000,
    fuelTankCapacity: 80,
    allowedCargoTypes: [.fragile(inHardcase: false), .bulk(inBricks: true)]
)

let vehicle2 = Vehicle(
    make: "Skoda",
    model: "Octavia",
    year: 2019,
    capacity: 300,
    fuelTankCapacity: 60
)

let truck1 = Truck(
    make: "Volvo",
    model: "FH",
    year: 2020,
    capacity: 5000,
    fuelTankCapacity: 200,
    trailerAttached: true,
    trailerCapacity: 2000,
    allowedCargoTypes: [.fragile(inHardcase: true), .perishable(temperature: -10)],
    trailerAllowedCargoTypes: [.bulk(inBricks: false)]
)

let truck2 = Truck(
    make: "Toyota",
    model: "Tacoma",
    year: 2018,
    capacity: 1500,
    fuelTankCapacity: 100,
    trailerAttached: false,
    trailerCapacity: nil,
    allowedCargoTypes: [.bulk(inBricks: false)]
)

print("Creating fleet:")

let fleet = Fleet()
fleet.addVehicle(vehicle1)
fleet.addVehicle(vehicle2)
fleet.addVehicle(truck1)
fleet.addVehicle(truck2)

let cargo1 = Cargo(description: "Musical equipment", weight: 300, type: .fragile(inHardcase: true))
let cargo2 = Cargo(description: "Medicines", weight: 200, type: .perishable(temperature: -10))
let cargo3 = Cargo(description: "Sand", weight: 1000, type: .bulk(inBricks: false))
let cargo4 = Cargo(description: "Cocoa powder", weight: 50, type: .bulk(inBricks: true))

print("\nTrying to load cargos:")

if let cargo1 = cargo1, let cargo2 = cargo2, let cargo3 = cargo3, let cargo4 = cargo4 {
    vehicle1.loadCargo(cargo: cargo1) // BAD fragile
    vehicle1.loadCargo(cargo: cargo2) // BAD perishable
    vehicle2.loadCargo(cargo: cargo4) // OK bulk
    truck1.loadCargo(cargo: cargo1)   // OK fragile
    truck1.loadCargo(cargo: cargo2)   // OK perishable
    truck2.loadCargo(cargo: cargo3)   // OK bulk
}

print()
fleet.info()
print()

for vehicle in fleet.vehicles {
    vehicle.unloadCargo()
}

let cargos = [cargo1!, cargo2!, cargo3!, cargo4!]
fleet.canGo(cargo: cargos, path: 100)
print()
fleet.canGo(cargo: cargos, path: 300)
print()
fleet.vehicles.remove(at: 2) // removed 'Toyota Tacoma'
fleet.canGo(cargo: cargos, path: 700)
