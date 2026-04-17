-- ============================================================
-- Stored Procedure: Insert shipment and log initial status
-- ============================================================

USE supply_chain_db;

DELIMITER $$

CREATE PROCEDURE sp_add_shipment(
    IN p_route_id INT,
    IN p_carrier_id INT,
    IN p_departure_date DATE,
    IN p_arrival_date DATE,
    IN p_cargo_type VARCHAR(50),
    IN p_weight_kg FLOAT
)
BEGIN
    INSERT INTO shipments (route_id, carrier_id, departure_date, arrival_date, current_status, cargo_type, weight_kg)
    VALUES (p_route_id, p_carrier_id, p_departure_date, p_arrival_date, 'In Transit', p_cargo_type, p_weight_kg);
END$$

DELIMITER ;

-- ============================================================
-- Stored Procedure: Update shipment status with transaction
-- ============================================================

DELIMITER $$

CREATE PROCEDURE sp_update_shipment_status(
    IN p_shipment_id INT,
    IN p_new_status VARCHAR(50)
)
BEGIN
    DECLARE v_exists INT;

    -- Check if shipment exists
    SELECT COUNT(*) INTO v_exists
    FROM shipments WHERE shipment_id = p_shipment_id;

    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Shipment ID does not exist';
    END IF;

    UPDATE shipments
    SET current_status = p_new_status
    WHERE shipment_id = p_shipment_id;
END$$

DELIMITER ;
