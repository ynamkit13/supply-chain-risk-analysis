from datetime import datetime
from db import get_connection


def validate_shipment(data):
    required_fields = ['route_id', 'carrier_id', 'departure_date', 'arrival_date', 'cargo_type', 'weight_kg']
    for field in required_fields:
        if field not in data or data[field] is None or data[field] == '':
            return False, f"Missing required field: {field}"

    # Validate weight_kg is a positive number
    try:
        weight = float(data['weight_kg'])
        if weight <= 0:
            return False, "weight_kg must be a positive number"
    except (ValueError, TypeError):
        return False, "weight_kg must be a valid number"

    # Validate dates
    try:
        departure = datetime.strptime(str(data['departure_date']), '%Y-%m-%d')
        arrival = datetime.strptime(str(data['arrival_date']), '%Y-%m-%d')
    except ValueError:
        return False, "Dates must be in YYYY-MM-DD format"

    if arrival <= departure:
        return False, "arrival_date must be after departure_date"

    # Validate route_id exists
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT route_id FROM routes WHERE route_id = %s", (data['route_id'],))
        if cursor.fetchone() is None:
            return False, f"route_id {data['route_id']} does not exist"

        cursor.execute("SELECT carrier_id FROM carriers WHERE carrier_id = %s", (data['carrier_id'],))
        if cursor.fetchone() is None:
            return False, f"carrier_id {data['carrier_id']} does not exist"
    finally:
        cursor.close()
        conn.close()

    return True, None
