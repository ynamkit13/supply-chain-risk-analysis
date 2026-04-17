-- ============================================================
-- Advanced Supply Chain Risk Analysis System
-- Database Schema — Version 2.0
-- ============================================================

DROP DATABASE IF EXISTS supply_chain_db;
CREATE DATABASE supply_chain_db;
USE supply_chain_db;

-- ============================================================
-- Table 1: ports
-- ============================================================
CREATE TABLE ports (
    port_id INT AUTO_INCREMENT PRIMARY KEY,
    port_name VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL
);

-- ============================================================
-- Table 2: carriers
-- ============================================================
CREATE TABLE carriers (
    carrier_id INT AUTO_INCREMENT PRIMARY KEY,
    carrier_name VARCHAR(50) NOT NULL,
    reliability_score FLOAT CHECK (reliability_score >= 0.0 AND reliability_score <= 10.0),
    carrier_type VARCHAR(20) CHECK (carrier_type IN ('Air', 'Sea', 'Land'))
);

-- ============================================================
-- Table 3: routes
-- ============================================================
CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    origin_port_id INT NOT NULL,
    destination_port_id INT NOT NULL,
    distance_km INT NOT NULL,
    expected_duration_hours INT NOT NULL,
    FOREIGN KEY (origin_port_id) REFERENCES ports(port_id),
    FOREIGN KEY (destination_port_id) REFERENCES ports(port_id)
);

-- ============================================================
-- Table 4: shipments
-- ============================================================
CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    route_id INT NOT NULL,
    carrier_id INT NOT NULL,
    departure_date DATE NOT NULL,
    arrival_date DATE NOT NULL,
    actual_delay_hours INT DEFAULT 0,
    delay_flag BOOLEAN DEFAULT 0,
    current_status VARCHAR(50) DEFAULT 'In Transit',
    cargo_type VARCHAR(50),
    weight_kg FLOAT,
    FOREIGN KEY (route_id) REFERENCES routes(route_id),
    FOREIGN KEY (carrier_id) REFERENCES carriers(carrier_id)
);

-- ============================================================
-- Table 5: weather_conditions
-- ============================================================
CREATE TABLE weather_conditions (
    weather_id INT AUTO_INCREMENT PRIMARY KEY,
    port_id INT NOT NULL,
    weather_type VARCHAR(50) NOT NULL,
    severity_level INT CHECK (severity_level >= 1 AND severity_level <= 10),
    recorded_date DATE NOT NULL,
    FOREIGN KEY (port_id) REFERENCES ports(port_id)
);

-- ============================================================
-- Table 6: shipment_status_logs
-- ============================================================
CREATE TABLE shipment_status_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    shipment_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id) ON DELETE CASCADE
);

-- ============================================================
-- Indexes on Foreign Key columns
-- ============================================================
CREATE INDEX idx_shipments_route_id ON shipments(route_id);
CREATE INDEX idx_shipments_carrier_id ON shipments(carrier_id);
CREATE INDEX idx_weather_conditions_port_id ON weather_conditions(port_id);
CREATE INDEX idx_status_logs_shipment_id ON shipment_status_logs(shipment_id);

