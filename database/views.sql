-- ============================================================
-- View: high_risk_shipments (delay > 24 hours)
-- ============================================================

USE supply_chain_db;

CREATE VIEW high_risk_shipments AS
SELECT
    s.shipment_id,
    s.route_id,
    s.carrier_id,
    c.carrier_name,
    s.departure_date,
    s.arrival_date,
    s.actual_delay_hours,
    s.delay_flag,
    s.current_status,
    s.cargo_type,
    s.weight_kg,
    r.origin_port_id,
    r.destination_port_id,
    r.distance_km,
    r.expected_duration_hours
FROM shipments s
JOIN routes r ON s.route_id = r.route_id
JOIN carriers c ON s.carrier_id = c.carrier_id
WHERE s.actual_delay_hours > 24;

-- ============================================================
-- View: Average delay per route (Aggregation — AVG, COUNT, GROUP BY)
-- ============================================================

CREATE VIEW vw_avg_delay_per_route AS
SELECT
    r.route_id,
    p1.port_name AS origin,
    p2.port_name AS destination,
    r.distance_km,
    r.expected_duration_hours,
    COUNT(s.shipment_id) AS total_shipments,
    ROUND(AVG(s.actual_delay_hours), 1) AS avg_delay_hours,
    SUM(s.delay_flag) AS high_risk_count
FROM routes r
JOIN shipments s ON r.route_id = s.route_id
JOIN ports p1 ON r.origin_port_id = p1.port_id
JOIN ports p2 ON r.destination_port_id = p2.port_id
GROUP BY r.route_id, p1.port_name, p2.port_name,
         r.distance_km, r.expected_duration_hours
ORDER BY avg_delay_hours DESC;

-- ============================================================
-- View: Carrier performance (Aggregation + LEFT JOIN)
-- ============================================================

CREATE VIEW vw_carrier_performance AS
SELECT
    c.carrier_id,
    c.carrier_name,
    c.reliability_score,
    c.carrier_type,
    COUNT(s.shipment_id) AS total_shipments,
    ROUND(AVG(s.actual_delay_hours), 1) AS avg_delay_hours,
    SUM(s.delay_flag) AS high_risk_count
FROM carriers c
LEFT JOIN shipments s ON c.carrier_id = s.carrier_id
GROUP BY c.carrier_id, c.carrier_name,
         c.reliability_score, c.carrier_type
ORDER BY avg_delay_hours ASC;

-- ============================================================
-- View: Shipments with above-average delay (Subquery in WHERE)
-- ============================================================

CREATE VIEW vw_above_avg_delay AS
SELECT
    s.shipment_id,
    s.route_id,
    c.carrier_name,
    s.cargo_type,
    s.departure_date,
    s.arrival_date,
    s.actual_delay_hours,
    r.expected_duration_hours,
    p1.port_name AS origin,
    p2.port_name AS destination
FROM shipments s
JOIN carriers c ON s.carrier_id = c.carrier_id
JOIN routes r ON s.route_id = r.route_id
JOIN ports p1 ON r.origin_port_id = p1.port_id
JOIN ports p2 ON r.destination_port_id = p2.port_id
WHERE s.actual_delay_hours > (
    SELECT AVG(actual_delay_hours) FROM shipments
)
ORDER BY s.actual_delay_hours DESC;

-- ============================================================
-- View: Weather and delay correlation (Subquery + Aggregation)
-- Links weather events at origin/destination ports near the
-- departure window to shipment delays
-- ============================================================

CREATE VIEW vw_weather_risk_correlation AS
SELECT
    s.shipment_id,
    c.carrier_name,
    p1.port_name AS origin,
    p2.port_name AS destination,
    s.departure_date,
    s.actual_delay_hours,
    s.delay_flag,
    w.weather_type,
    w.severity_level,
    w.recorded_date AS weather_date,
    wp.port_name AS affected_port
FROM shipments s
JOIN routes r ON s.route_id = r.route_id
JOIN carriers c ON s.carrier_id = c.carrier_id
JOIN ports p1 ON r.origin_port_id = p1.port_id
JOIN ports p2 ON r.destination_port_id = p2.port_id
JOIN weather_conditions w ON w.port_id IN (r.origin_port_id, r.destination_port_id)
JOIN ports wp ON w.port_id = wp.port_id
WHERE w.recorded_date BETWEEN
    DATE_SUB(s.departure_date, INTERVAL 7 DAY) AND s.arrival_date
  AND w.severity_level >= 5
ORDER BY s.actual_delay_hours DESC;
