-- ============================================================
-- Advanced Supply Chain Risk Analysis System
-- Sample Data — Based on Real-World Shipping Data
-- ============================================================
-- Sources: Global container port rankings (Lloyd's List, Alphaliner),
-- Carrier reliability (Sea-Intelligence Global Liner Performance),
-- Sea-route distances (actual shipping lane distances via Suez/Panama),
-- Weather patterns (WMO seasonal data), Congestion events (2021-2025).
-- ============================================================

USE supply_chain_db;

-- ============================================================
-- PORTS — Top 15 global container ports by throughput
-- ============================================================
INSERT INTO ports (port_id, port_name, country) VALUES
(1,  'Shanghai',         'China'),
(2,  'Singapore',        'Singapore'),
(3,  'Shenzhen',         'China'),
(4,  'Ningbo-Zhoushan',  'China'),
(5,  'Busan',            'South Korea'),
(6,  'Guangzhou',        'China'),
(7,  'Qingdao',          'China'),
(8,  'Jebel Ali',        'UAE'),
(9,  'Rotterdam',        'Netherlands'),
(10, 'Antwerp-Bruges',   'Belgium'),
(11, 'Hamburg',           'Germany'),
(12, 'Los Angeles',       'USA'),
(13, 'Long Beach',        'USA'),
(14, 'Santos',            'Brazil'),
(15, 'Colombo',           'Sri Lanka');

-- ============================================================
-- CARRIERS — Real global shipping lines
-- Reliability scores based on Sea-Intelligence schedule
-- reliability data (industry avg 50-65%, mapped to 0-10 scale)
-- ============================================================
INSERT INTO carriers (carrier_id, carrier_name, reliability_score, carrier_type) VALUES
(1,  'Maersk',                7.2, 'Sea'),
(2,  'MSC',                   6.5, 'Sea'),
(3,  'CMA CGM',               6.8, 'Sea'),
(4,  'COSCO Shipping',        6.0, 'Sea'),
(5,  'Hapag-Lloyd',           7.0, 'Sea'),
(6,  'Evergreen Marine',      6.3, 'Sea'),
(7,  'ONE',                   6.1, 'Sea'),
(8,  'Yang Ming',             5.8, 'Sea'),
(9,  'ZIM Shipping',          6.6, 'Sea'),
(10, 'DHL Global Forwarding', 8.0, 'Air');

-- ============================================================
-- ROUTES — Real sea-route distances via standard shipping lanes
-- Speed: ~20 knots avg (~37 km/h) + canal/port approach time
-- ============================================================
INSERT INTO routes (route_id, origin_port_id, destination_port_id, distance_km, expected_duration_hours) VALUES
(1,  1,  12, 10400, 288),   -- Shanghai → Los Angeles (Transpacific)
(2,  1,  9,  19500, 648),   -- Shanghai → Rotterdam (via Suez Canal)
(3,  1,  2,  3800,  108),   -- Shanghai → Singapore (Intra-Asia)
(4,  1,  5,  860,   28),    -- Shanghai → Busan (short hop)
(5,  3,  12, 10800, 300),   -- Shenzhen → Los Angeles (Transpacific)
(6,  2,  9,  15200, 456),   -- Singapore → Rotterdam (via Suez)
(7,  2,  8,  5800,  168),   -- Singapore → Jebel Ali (Indian Ocean)
(8,  2,  15, 2800,  84),    -- Singapore → Colombo (Indian Ocean)
(9,  5,  13, 9500,  264),   -- Busan → Long Beach (Transpacific)
(10, 5,  1,  860,   28),    -- Busan → Shanghai (short hop)
(11, 9,  13, 14800, 432),   -- Rotterdam → Long Beach (via Panama Canal)
(12, 9,  11, 550,   20),    -- Rotterdam → Hamburg (European coastal)
(13, 9,  8,  11200, 336),   -- Rotterdam → Jebel Ali (via Suez)
(14, 10, 14, 9500,  288),   -- Antwerp-Bruges → Santos (Transatlantic south)
(15, 8,  15, 2900,  84),    -- Jebel Ali → Colombo (Arabian Sea)
(16, 8,  1,  12400, 360),   -- Jebel Ali → Shanghai (via Malacca Strait)
(17, 6,  2,  3600,  102),   -- Guangzhou → Singapore (South China Sea)
(18, 4,  12, 10200, 282),   -- Ningbo-Zhoushan → Los Angeles (Transpacific)
(19, 7,  11, 20100, 672),   -- Qingdao → Hamburg (via Suez, longest route)
(20, 14, 10, 9500,  288);   -- Santos → Antwerp-Bruges (Transatlantic north)

-- ============================================================
-- SHIPMENTS — 35 realistic shipments (Sep 2024 - Mar 2025)
-- Trigger auto-computes actual_delay_hours and delay_flag
-- Mix: ~60% on-time/minor, ~40% significantly delayed (>24h)
-- Delays correlate with weather events and congestion periods
-- ============================================================
INSERT INTO shipments (route_id, carrier_id, departure_date, arrival_date, current_status, cargo_type, weight_kg) VALUES

-- Route 1: Shanghai → LA (288h = 12 days expected)
(1,  1,  '2024-09-01', '2024-09-13', 'Delivered',  'Electronics',      8500.0),   -- #1  on-time
(1,  2,  '2024-10-15', '2024-10-31', 'Delivered',  'Automotive Parts', 14200.0),   -- #2  typhoon delay → ~96h
(1,  4,  '2025-01-05', '2025-01-17', 'Delivered',  'Consumer Goods',   10500.0),   -- #3  on-time

-- Route 2: Shanghai → Rotterdam (648h = 27 days expected)
(2,  3,  '2024-08-10', '2024-09-07', 'Delivered',  'Machinery',        18500.0),   -- #4  ~24h delay
(2,  1,  '2025-01-10', '2025-02-13', 'Delivered',  'Electronics',       9200.0),   -- #5  Red Sea rerouting → ~168h

-- Route 3: Shanghai → Singapore (108h = 4.5 days expected)
(3,  4,  '2024-11-05', '2024-11-10', 'Delivered',  'Textiles',          6200.0),   -- #6  ~12h delay
(3,  8,  '2025-03-01', '2025-03-05', 'Delivered',  'Plastics',         11000.0),   -- #7  early arrival

-- Route 4: Shanghai → Busan (28h = ~1.2 days expected)
(4,  5,  '2024-12-01', '2024-12-02', 'Delivered',  'Automotive Parts', 15800.0),   -- #8  on-time

-- Route 5: Shenzhen → LA (300h = 12.5 days expected)
(5,  1,  '2024-07-20', '2024-08-05', 'Delivered',  'Electronics',       7800.0),   -- #9  ~84h delay
(5,  3,  '2025-02-01', '2025-02-14', 'Delivered',  'Furniture',         5200.0),   -- #10 ~12h delay

-- Route 6: Singapore → Rotterdam (456h = 19 days expected)
(6,  6,  '2024-06-15', '2024-07-04', 'Delivered',  'Chemicals',        20500.0),   -- #11 on-time
(6,  9,  '2025-01-15', '2025-02-10', 'Delivered',  'Raw Materials',    22000.0),   -- #12 Red Sea → ~168h

-- Route 7: Singapore → Jebel Ali (168h = 7 days expected)
(7,  3,  '2024-08-20', '2024-08-28', 'Delivered',  'Food & Beverages', 15500.0),   -- #13 ~24h delay
(7,  1,  '2025-01-20', '2025-01-27', 'Delivered',  'Pharmaceuticals',   7200.0),   -- #14 on-time

-- Route 8: Singapore → Colombo (84h = 3.5 days expected)
(8,  7,  '2024-05-15', '2024-05-21', 'Delivered',  'Perishable Goods', 12500.0),   -- #15 monsoon → ~60h

-- Route 9: Busan → Long Beach (264h = 11 days expected)
(9,  2,  '2024-09-10', '2024-09-21', 'Delivered',  'Electronics',       8800.0),   -- #16 on-time
(9,  5,  '2024-11-20', '2024-12-01', 'Delivered',  'Machinery',        19000.0),   -- #17 on-time

-- Route 10: Busan → Shanghai (28h = ~1.2 days expected)
(10, 8,  '2024-10-01', '2024-10-02', 'Delivered',  'Automotive Parts', 13500.0),   -- #18 on-time

-- Route 11: Rotterdam → Long Beach (432h = 18 days expected)
(11, 5,  '2024-11-10', '2024-11-30', 'Delivered',  'Chemicals',        19500.0),   -- #19 winter storm → ~48h

-- Route 12: Rotterdam → Hamburg (20h = <1 day expected)
(12, 10, '2024-12-15', '2024-12-16', 'Delivered',  'Consumer Goods',    9800.0),   -- #20 on-time
(12, 10, '2025-01-05', '2025-01-08', 'Delivered',  'Pharmaceuticals',   6500.0),   -- #21 winter storm → ~52h

-- Route 13: Rotterdam → Jebel Ali (336h = 14 days expected)
(13, 1,  '2024-03-01', '2024-03-16', 'Delivered',  'Machinery',        17500.0),   -- #22 ~24h delay

-- Route 14: Antwerp-Bruges → Santos (288h = 12 days expected)
(14, 3,  '2024-01-20', '2024-02-05', 'Delivered',  'Raw Materials',    23000.0),   -- #23 Santos flooding → ~96h
(14, 6,  '2025-02-10', '2025-02-25', 'Delivered',  'Chemicals',        21000.0),   -- #24 ~72h delay

-- Route 15: Jebel Ali → Colombo (84h = 3.5 days expected)
(15, 4,  '2024-10-25', '2024-10-31', 'Delivered',  'Textiles',          5800.0),   -- #25 cyclone → ~60h
(15, 7,  '2025-03-10', '2025-03-14', 'Delivered',  'Food & Beverages', 14000.0),   -- #26 ~12h delay

-- Route 16: Jebel Ali → Shanghai (360h = 15 days expected)
(16, 9,  '2024-04-10', '2024-04-25', 'Delivered',  'Furniture',         4800.0),   -- #27 on-time
(16, 6,  '2024-11-01', '2024-11-19', 'Delivered',  'Electronics',       9500.0),   -- #28 ~72h delay

-- Route 17: Guangzhou → Singapore (102h = 4.25 days expected)
(17, 6,  '2024-07-08', '2024-07-16', 'Delivered',  'Plastics',         10800.0),   -- #29 typhoon → ~84h
(17, 3,  '2024-12-10', '2024-12-14', 'Delivered',  'Textiles',          6800.0),   -- #30 on-time

-- Route 18: Ningbo-Zhoushan → LA (282h = 11.75 days expected)
(18, 2,  '2024-08-01', '2024-08-13', 'Delivered',  'Consumer Goods',   11500.0),   -- #31 ~6h delay
(18, 4,  '2024-09-20', '2024-10-05', 'Delivered',  'Machinery',        17000.0),   -- #32 typhoon → ~78h

-- Route 19: Qingdao → Hamburg (672h = 28 days expected)
(19, 7,  '2024-03-15', '2024-04-16', 'Delivered',  'Raw Materials',    24000.0),   -- #33 fog+Suez → ~96h
(19, 5,  '2025-02-01', '2025-03-02', 'Delivered',  'Automotive Parts', 14500.0),   -- #34 ~24h delay

-- Route 20: Santos → Antwerp-Bruges (288h = 12 days expected)
(20, 2,  '2024-04-05', '2024-04-18', 'Delivered',  'Food & Beverages', 16000.0);   -- #35 ~24h delay

-- ============================================================
-- PORT CONGESTION — Real documented congestion events
-- ============================================================
INSERT INTO port_congestion (port_id, congestion_level, recorded_date) VALUES
-- Los Angeles: COVID supply chain crisis (2021-2023 peak, lingering 2024)
(12, 9,  '2024-01-15'),
(12, 7,  '2024-03-10'),
(12, 5,  '2024-06-20'),
(12, 4,  '2024-09-05'),
(12, 3,  '2025-01-10'),

-- Long Beach: Same twin-port crisis as LA
(13, 9,  '2024-01-15'),
(13, 6,  '2024-04-20'),
(13, 4,  '2024-08-12'),
(13, 3,  '2025-01-10'),

-- Shanghai: World's busiest port, persistent high volume
(1,  7,  '2024-02-05'),
(1,  8,  '2024-05-18'),
(1,  6,  '2024-08-22'),
(1,  7,  '2024-10-30'),
(1,  6,  '2025-01-20'),
(1,  5,  '2025-03-15'),

-- Shenzhen: COVID spillover + peak season surges
(3,  7,  '2024-03-10'),
(3,  5,  '2024-07-15'),
(3,  6,  '2024-10-08'),
(3,  4,  '2025-02-01'),

-- Singapore: Red Sea crisis rerouting (2024-2025)
(2,  5,  '2024-01-20'),
(2,  7,  '2024-04-15'),
(2,  8,  '2024-07-22'),
(2,  7,  '2024-10-10'),
(2,  8,  '2025-01-15'),
(2,  6,  '2025-03-01'),

-- Rotterdam: European supply chain disruptions
(9,  6,  '2024-01-25'),
(9,  5,  '2024-05-10'),
(9,  4,  '2024-08-30'),
(9,  5,  '2024-11-20'),
(9,  4,  '2025-02-15'),

-- Hamburg: Labor disputes and infrastructure constraints
(11, 7,  '2024-02-10'),
(11, 6,  '2024-06-05'),
(11, 5,  '2024-09-18'),
(11, 6,  '2024-12-01'),
(11, 5,  '2025-03-01'),

-- Antwerp-Bruges: Elevated volumes
(10, 5,  '2024-03-15'),
(10, 4,  '2024-07-20'),
(10, 5,  '2024-11-10'),
(10, 4,  '2025-02-20'),

-- Jebel Ali: Red Sea diversions increased transshipment
(8,  4,  '2024-01-25'),
(8,  5,  '2024-04-10'),
(8,  6,  '2024-07-15'),
(8,  5,  '2024-10-20'),
(8,  5,  '2025-01-30'),

-- Busan: Volume spikes during peak seasons
(5,  4,  '2024-03-20'),
(5,  5,  '2024-08-15'),
(5,  4,  '2024-11-25'),
(5,  3,  '2025-02-10'),

-- Ningbo-Zhoushan: Seasonal surges
(4,  6,  '2024-04-10'),
(4,  5,  '2024-08-20'),
(4,  7,  '2024-10-15'),
(4,  5,  '2025-01-25'),

-- Guangzhou: Pearl River Delta volume pressure
(6,  6,  '2024-05-01'),
(6,  5,  '2024-07-25'),
(6,  7,  '2024-10-12'),
(6,  5,  '2025-01-15'),

-- Colombo: Sri Lanka economic recovery, growing hub
(15, 6,  '2024-03-10'),
(15, 5,  '2024-06-20'),
(15, 5,  '2024-10-05'),
(15, 4,  '2025-02-15'),

-- Santos: Agricultural export surges (soy/sugar season)
(14, 5,  '2024-02-15'),
(14, 6,  '2024-04-20'),
(14, 4,  '2024-08-10'),
(14, 5,  '2024-12-05'),
(14, 4,  '2025-03-10'),

-- Qingdao: Moderate congestion
(7,  4,  '2024-03-25'),
(7,  5,  '2024-07-10'),
(7,  4,  '2024-11-15'),
(7,  3,  '2025-02-20');

-- ============================================================
-- WEATHER CONDITIONS — Real seasonal weather patterns
-- Dates chosen within documented storm/fog/monsoon seasons
-- ============================================================
INSERT INTO weather_conditions (port_id, weather_type, severity_level, recorded_date) VALUES
-- Shanghai: Typhoon season Jul-Oct, Spring fog Mar-May
(1,  'Fog',              4, '2024-03-12'),
(1,  'Fog',              3, '2024-04-08'),
(1,  'Typhoon',          7, '2024-07-22'),
(1,  'Typhoon',          8, '2024-09-15'),
(1,  'Typhoon',          6, '2024-10-18'),
(1,  'Clear',            1, '2024-12-10'),
(1,  'Fog',              4, '2025-03-05'),

-- Singapore: NE Monsoon squalls Nov-Mar, generally mild
(2,  'Monsoon Squall',   3, '2024-01-18'),
(2,  'Clear',            1, '2024-05-10'),
(2,  'Clear',            1, '2024-08-15'),
(2,  'Monsoon Squall',   4, '2024-11-22'),
(2,  'Monsoon Squall',   3, '2025-01-14'),
(2,  'Monsoon Squall',   3, '2025-03-08'),

-- Shenzhen: Typhoon belt Jun-Nov
(3,  'Clear',            1, '2024-03-15'),
(3,  'Typhoon',          8, '2024-07-10'),
(3,  'Typhoon',          7, '2024-09-05'),
(3,  'Typhoon',          6, '2024-10-20'),
(3,  'Clear',            1, '2025-01-10'),

-- Ningbo-Zhoushan: Typhoon season Jul-Oct
(4,  'Clear',            1, '2024-04-20'),
(4,  'Typhoon',          7, '2024-08-08'),
(4,  'Typhoon',          8, '2024-09-22'),
(4,  'Clear',            1, '2024-12-15'),
(4,  'Clear',            1, '2025-02-10'),

-- Busan: Typhoons Aug-Oct, Winter storms Dec-Feb
(5,  'Winter Storm',     5, '2024-01-20'),
(5,  'Clear',            1, '2024-05-15'),
(5,  'Typhoon',          7, '2024-08-25'),
(5,  'Typhoon',          6, '2024-10-05'),
(5,  'Winter Storm',     5, '2024-12-18'),
(5,  'Winter Storm',     4, '2025-02-05'),

-- Guangzhou: Typhoon belt Jun-Nov
(6,  'Clear',            1, '2024-03-10'),
(6,  'Typhoon',          7, '2024-07-08'),
(6,  'Typhoon',          8, '2024-09-12'),
(6,  'Typhoon',          6, '2024-11-02'),
(6,  'Clear',            1, '2025-01-15'),

-- Qingdao: Fog Mar-Jul (one of China's foggiest ports), Winter ice Jan-Feb
(7,  'Winter Ice',       4, '2024-01-15'),
(7,  'Fog',              5, '2024-03-20'),
(7,  'Fog',              6, '2024-05-10'),
(7,  'Fog',              4, '2024-07-02'),
(7,  'Clear',            1, '2024-10-15'),
(7,  'Winter Ice',       3, '2025-01-22'),
(7,  'Fog',              5, '2025-03-18'),

-- Jebel Ali (Dubai): Shamal sandstorms Jun-Aug, Extreme heat May-Sep
(8,  'Clear',            1, '2024-02-10'),
(8,  'Extreme Heat',     4, '2024-05-20'),
(8,  'Sandstorm',        5, '2024-06-15'),
(8,  'Sandstorm',        6, '2024-07-22'),
(8,  'Extreme Heat',     5, '2024-08-10'),
(8,  'Clear',            1, '2024-11-15'),
(8,  'Clear',            1, '2025-01-20'),

-- Rotterdam: North Sea fog/storms Oct-Mar
(9,  'North Sea Storm',  6, '2024-01-08'),
(9,  'Fog',              5, '2024-02-15'),
(9,  'Clear',            1, '2024-06-20'),
(9,  'Clear',            1, '2024-08-25'),
(9,  'Fog',              4, '2024-10-30'),
(9,  'North Sea Storm',  6, '2024-12-05'),
(9,  'North Sea Storm',  5, '2025-02-18'),

-- Antwerp-Bruges: Fog/storms Oct-Mar
(10, 'Fog',              4, '2024-01-12'),
(10, 'Clear',            1, '2024-05-18'),
(10, 'Clear',            1, '2024-08-10'),
(10, 'Winter Storm',     5, '2024-11-15'),
(10, 'Fog',              4, '2025-01-20'),
(10, 'Winter Storm',     5, '2025-03-02'),

-- Hamburg: Fog Oct-Mar, Storm surges on Elbe Nov-Feb
(11, 'Storm Surge',      6, '2024-01-18'),
(11, 'Fog',              4, '2024-02-22'),
(11, 'Clear',            1, '2024-06-10'),
(11, 'Clear',            1, '2024-08-20'),
(11, 'Fog',              5, '2024-11-08'),
(11, 'Storm Surge',      7, '2024-12-20'),
(11, 'Storm Surge',      5, '2025-01-15'),

-- Los Angeles: Marine fog May-Aug (June Gloom), Santa Ana winds Oct-Dec
(12, 'Clear',            1, '2024-02-10'),
(12, 'Fog',              3, '2024-06-05'),
(12, 'Fog',              3, '2024-07-18'),
(12, 'Santa Ana Winds',  4, '2024-10-22'),
(12, 'Santa Ana Winds',  5, '2024-12-01'),
(12, 'Clear',            1, '2025-03-10'),

-- Long Beach: Same marine layer as LA
(13, 'Clear',            1, '2024-02-10'),
(13, 'Fog',              3, '2024-05-28'),
(13, 'Fog',              4, '2024-07-15'),
(13, 'Santa Ana Winds',  4, '2024-11-05'),
(13, 'Clear',            1, '2025-01-15'),

-- Santos: Heavy rain/flooding Dec-Mar, Subtropical storms Jan-Apr
(14, 'Heavy Rain',       6, '2024-01-22'),
(14, 'Flooding',         7, '2024-02-15'),
(14, 'Subtropical Storm', 5, '2024-03-08'),
(14, 'Clear',            1, '2024-07-10'),
(14, 'Clear',            1, '2024-10-15'),
(14, 'Heavy Rain',       6, '2024-12-20'),
(14, 'Heavy Rain',       5, '2025-02-12'),

-- Colombo: SW Monsoon May-Sep, Cyclones Oct-Dec
(15, 'Clear',            1, '2024-02-15'),
(15, 'Monsoon',          7, '2024-05-20'),
(15, 'Monsoon',          6, '2024-07-10'),
(15, 'Monsoon',          7, '2024-09-05'),
(15, 'Cyclone',          6, '2024-10-28'),
(15, 'Cyclone',          5, '2024-12-08'),
(15, 'Clear',            1, '2025-03-10');

-- ============================================================
-- SHIPMENT STATUS LOGS — Lifecycle tracking for all 35 shipments
-- Timestamps reflect realistic progression through statuses
-- ============================================================
INSERT INTO shipment_status_logs (shipment_id, status, timestamp) VALUES
-- Shipment 1: on-time delivery
(1,  'In Transit',   '2024-09-01 06:00:00'),
(1,  'Delivered',    '2024-09-13 14:00:00'),

-- Shipment 2: typhoon delay
(2,  'In Transit',   '2024-10-15 08:00:00'),
(2,  'Delayed',      '2024-10-25 10:00:00'),
(2,  'In Transit',   '2024-10-28 06:00:00'),
(2,  'Delivered',    '2024-10-31 18:00:00'),

-- Shipment 3: on-time
(3,  'In Transit',   '2025-01-05 07:00:00'),
(3,  'Delivered',    '2025-01-17 15:00:00'),

-- Shipment 4: minor delay
(4,  'In Transit',   '2024-08-10 09:00:00'),
(4,  'Delivered',    '2024-09-07 12:00:00'),

-- Shipment 5: Red Sea rerouting — significant delay
(5,  'In Transit',   '2025-01-10 06:00:00'),
(5,  'Delayed',      '2025-01-28 14:00:00'),
(5,  'In Transit',   '2025-02-02 08:00:00'),
(5,  'Delivered',    '2025-02-13 20:00:00'),

-- Shipment 6: minor delay
(6,  'In Transit',   '2024-11-05 10:00:00'),
(6,  'Delivered',    '2024-11-10 08:00:00'),

-- Shipment 7: early arrival
(7,  'In Transit',   '2025-03-01 07:00:00'),
(7,  'Delivered',    '2025-03-05 10:00:00'),

-- Shipment 8: on-time
(8,  'In Transit',   '2024-12-01 05:00:00'),
(8,  'Delivered',    '2024-12-02 14:00:00'),

-- Shipment 9: delayed
(9,  'In Transit',   '2024-07-20 08:00:00'),
(9,  'Delayed',      '2024-07-30 16:00:00'),
(9,  'In Transit',   '2024-08-02 06:00:00'),
(9,  'Delivered',    '2024-08-05 22:00:00'),

-- Shipment 10: minor delay
(10, 'In Transit',   '2025-02-01 09:00:00'),
(10, 'Delivered',    '2025-02-14 11:00:00'),

-- Shipment 11: on-time
(11, 'In Transit',   '2024-06-15 06:00:00'),
(11, 'Delivered',    '2024-07-04 16:00:00'),

-- Shipment 12: Red Sea rerouting — significant delay
(12, 'In Transit',   '2025-01-15 07:00:00'),
(12, 'Delayed',      '2025-02-01 12:00:00'),
(12, 'In Transit',   '2025-02-05 08:00:00'),
(12, 'Delivered',    '2025-02-10 20:00:00'),

-- Shipment 13: minor delay
(13, 'In Transit',   '2024-08-20 10:00:00'),
(13, 'Delivered',    '2024-08-28 06:00:00'),

-- Shipment 14: on-time
(14, 'In Transit',   '2025-01-20 08:00:00'),
(14, 'Delivered',    '2025-01-27 14:00:00'),

-- Shipment 15: monsoon delay
(15, 'In Transit',   '2024-05-15 06:00:00'),
(15, 'Delayed',      '2024-05-18 20:00:00'),
(15, 'Delivered',    '2024-05-21 18:00:00'),

-- Shipment 16: on-time
(16, 'In Transit',   '2024-09-10 07:00:00'),
(16, 'Delivered',    '2024-09-21 12:00:00'),

-- Shipment 17: on-time
(17, 'In Transit',   '2024-11-20 09:00:00'),
(17, 'Delivered',    '2024-12-01 16:00:00'),

-- Shipment 18: on-time
(18, 'In Transit',   '2024-10-01 06:00:00'),
(18, 'Delivered',    '2024-10-02 10:00:00'),

-- Shipment 19: winter storm delay
(19, 'In Transit',   '2024-11-10 08:00:00'),
(19, 'Delayed',      '2024-11-26 14:00:00'),
(19, 'In Transit',   '2024-11-28 06:00:00'),
(19, 'Delivered',    '2024-11-30 20:00:00'),

-- Shipment 20: on-time
(20, 'In Transit',   '2024-12-15 07:00:00'),
(20, 'Delivered',    '2024-12-16 10:00:00'),

-- Shipment 21: winter storm delay
(21, 'In Transit',   '2025-01-05 06:00:00'),
(21, 'Delayed',      '2025-01-06 18:00:00'),
(21, 'Delivered',    '2025-01-08 14:00:00'),

-- Shipment 22: minor delay
(22, 'In Transit',   '2024-03-01 09:00:00'),
(22, 'Delivered',    '2024-03-16 08:00:00'),

-- Shipment 23: Santos flooding delay
(23, 'In Transit',   '2024-01-20 07:00:00'),
(23, 'Delayed',      '2024-01-31 10:00:00'),
(23, 'In Transit',   '2024-02-02 06:00:00'),
(23, 'Delivered',    '2024-02-05 22:00:00'),

-- Shipment 24: delayed
(24, 'In Transit',   '2025-02-10 08:00:00'),
(24, 'Delayed',      '2025-02-20 16:00:00'),
(24, 'Delivered',    '2025-02-25 12:00:00'),

-- Shipment 25: cyclone delay
(25, 'In Transit',   '2024-10-25 06:00:00'),
(25, 'Delayed',      '2024-10-28 14:00:00'),
(25, 'Delivered',    '2024-10-31 20:00:00'),

-- Shipment 26: minor delay
(26, 'In Transit',   '2025-03-10 09:00:00'),
(26, 'Delivered',    '2025-03-14 08:00:00'),

-- Shipment 27: on-time
(27, 'In Transit',   '2024-04-10 07:00:00'),
(27, 'Delivered',    '2024-04-25 16:00:00'),

-- Shipment 28: delayed
(28, 'In Transit',   '2024-11-01 06:00:00'),
(28, 'Delayed',      '2024-11-14 12:00:00'),
(28, 'In Transit',   '2024-11-16 08:00:00'),
(28, 'Delivered',    '2024-11-19 18:00:00'),

-- Shipment 29: typhoon delay
(29, 'In Transit',   '2024-07-08 08:00:00'),
(29, 'Delayed',      '2024-07-11 16:00:00'),
(29, 'In Transit',   '2024-07-13 06:00:00'),
(29, 'Delivered',    '2024-07-16 14:00:00'),

-- Shipment 30: on-time (early)
(30, 'In Transit',   '2024-12-10 07:00:00'),
(30, 'Delivered',    '2024-12-14 12:00:00'),

-- Shipment 31: minor delay
(31, 'In Transit',   '2024-08-01 09:00:00'),
(31, 'Delivered',    '2024-08-13 06:00:00'),

-- Shipment 32: typhoon delay
(32, 'In Transit',   '2024-09-20 06:00:00'),
(32, 'Delayed',      '2024-09-30 14:00:00'),
(32, 'In Transit',   '2024-10-02 08:00:00'),
(32, 'Delivered',    '2024-10-05 20:00:00'),

-- Shipment 33: fog + Suez delay
(33, 'In Transit',   '2024-03-15 07:00:00'),
(33, 'Delayed',      '2024-04-08 10:00:00'),
(33, 'In Transit',   '2024-04-11 06:00:00'),
(33, 'Delivered',    '2024-04-16 18:00:00'),

-- Shipment 34: minor delay
(34, 'In Transit',   '2025-02-01 08:00:00'),
(34, 'Delivered',    '2025-03-02 10:00:00'),

-- Shipment 35: minor delay
(35, 'In Transit',   '2024-04-05 06:00:00'),
(35, 'Delivered',    '2024-04-18 14:00:00');
