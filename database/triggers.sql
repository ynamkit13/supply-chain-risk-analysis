-- ============================================================
-- Trigger: Auto-compute actual_delay_hours and delay_flag
-- on every INSERT into shipments
-- ============================================================

USE supply_chain_db;

DELIMITER $$

CREATE TRIGGER trg_compute_delay
BEFORE INSERT ON shipments
FOR EACH ROW
BEGIN
    DECLARE v_expected_duration INT;
    DECLARE v_expected_arrival DATE;

    -- Fetch expected duration from the route
    SELECT expected_duration_hours INTO v_expected_duration
    FROM routes
    WHERE route_id = NEW.route_id;

    -- Compute expected arrival date
    SET v_expected_arrival = DATE_ADD(NEW.departure_date, INTERVAL v_expected_duration HOUR);

    -- Compute actual delay in hours
    SET NEW.actual_delay_hours = TIMESTAMPDIFF(HOUR, v_expected_arrival, NEW.arrival_date);

    -- Set delay flag: 1 if delay exceeds 24 hours, else 0
    IF NEW.actual_delay_hours > 24 THEN
        SET NEW.delay_flag = 1;
    ELSE
        SET NEW.delay_flag = 0;
    END IF;
END$$

DELIMITER ;

