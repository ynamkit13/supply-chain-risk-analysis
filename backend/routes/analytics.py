from flask import Blueprint, jsonify
from db import get_connection

analytics_bp = Blueprint('analytics', __name__)


@analytics_bp.route('/avg-delay-route', methods=['GET'])
def get_avg_delay_route():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM vw_avg_delay_per_route")
        rows = cursor.fetchall()
        return jsonify(rows), 200
    finally:
        cursor.close()
        conn.close()


@analytics_bp.route('/carrier-performance', methods=['GET'])
def get_carrier_performance():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM vw_carrier_performance")
        rows = cursor.fetchall()
        return jsonify(rows), 200
    finally:
        cursor.close()
        conn.close()
