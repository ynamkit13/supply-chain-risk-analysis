from flask import Blueprint, jsonify
from db import get_connection

risk_bp = Blueprint('risk', __name__)


@risk_bp.route('/high-risk', methods=['GET'])
def get_high_risk():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM high_risk_shipments")
        rows = cursor.fetchall()

        for row in rows:
            row['departure_date'] = str(row['departure_date'])
            row['arrival_date'] = str(row['arrival_date'])

        return jsonify(rows), 200
    finally:
        cursor.close()
        conn.close()


@risk_bp.route('/ranked-shipments', methods=['GET'])
def get_ranked_shipments():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM vw_ranked_shipments")
        rows = cursor.fetchall()
        return jsonify(rows), 200
    finally:
        cursor.close()
        conn.close()


@risk_bp.route('/above-avg-delay', methods=['GET'])
def get_above_avg_delay():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM vw_above_avg_delay")
        rows = cursor.fetchall()

        for row in rows:
            row['departure_date'] = str(row['departure_date'])
            row['arrival_date'] = str(row['arrival_date'])

        return jsonify(rows), 200
    finally:
        cursor.close()
        conn.close()


@risk_bp.route('/weather-correlation', methods=['GET'])
def get_weather_correlation():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM vw_weather_risk_correlation")
        rows = cursor.fetchall()

        for row in rows:
            row['departure_date'] = str(row['departure_date'])
            row['weather_date'] = str(row['weather_date'])

        return jsonify(rows), 200
    finally:
        cursor.close()
        conn.close()
