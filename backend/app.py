from flask import Flask
from flask_cors import CORS
from routes.shipments import shipments_bp
from routes.risk import risk_bp
from routes.analytics import analytics_bp

app = Flask(__name__)
CORS(app)

# Register blueprints
app.register_blueprint(shipments_bp)
app.register_blueprint(risk_bp)
app.register_blueprint(analytics_bp)

if __name__ == '__main__':
    app.run(debug=True, port=5001)
