from flask import Blueprint, jsonify, request
from db import get_connection
from validation import validate_shipment

shipments_bp = Blueprint('shipments', __name__)


@shipments_bp.route('/shipments', methods=['GET'])
def get_shipments():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("""
            SELECT s.shipment_id, s.route_id, s.carrier_id,
                   s.departure_date, s.arrival_date,
                   s.actual_delay_hours, s.delay_flag,
                   s.current_status, s.cargo_type, s.weight_kg,
                   r.origin_port_id, r.destination_port_id,
                   r.distance_km, r.expected_duration_hours,
                   c.carrier_name, c.carrier_type,
                   p1.port_name AS origin_port, p1.country AS origin_country,
                   p2.port_name AS destination_port, p2.country AS destination_country
            FROM shipments s
            JOIN routes r ON s.route_id = r.route_id
            JOIN carriers c ON s.carrier_id = c.carrier_id
            JOIN ports p1 ON r.origin_port_id = p1.port_id
            JOIN ports p2 ON r.destination_port_id = p2.port_id
            ORDER BY s.shipment_id
        """)
        rows = cursor.fetchall()

        # Convert date objects to strings for JSON serialization
        for row in rows:
            row['departure_date'] = str(row['departure_date'])
            row['arrival_date'] = str(row['arrival_date'])

        return jsonify(rows), 200
    finally:
        cursor.close()
        conn.close()


@shipments_bp.route('/add-shipment', methods=['POST'])
def add_shipment():
    data = request.get_json()
    if not data:
        return jsonify({'error': 'Request body must be JSON'}), 400

    is_valid, error_message = validate_shipment(data)
    if not is_valid:
        return jsonify({'error': error_message}), 400

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.callproc('sp_add_shipment', [
            data['route_id'],
            data['carrier_id'],
            data['departure_date'],
            data['arrival_date'],
            data['cargo_type'],
            float(data['weight_kg'])
        ])
        conn.commit()
        return jsonify({'message': 'Shipment added successfully'}), 201
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()


@shipments_bp.route('/update-status', methods=['PUT'])
def update_status():
    data = request.get_json()
    if not data:
        return jsonify({'error': 'Request body must be JSON'}), 400

    shipment_id = data.get('shipment_id')
    new_status = data.get('status')

    if not shipment_id or not new_status:
        return jsonify({'error': 'shipment_id and status are required'}), 400

    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.callproc('sp_update_shipment_status', [
            int(shipment_id),
            new_status
        ])
        conn.commit()
        return jsonify({'message': 'Status updated successfully'}), 200
    except Exception as e:
        conn.rollback()
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()
